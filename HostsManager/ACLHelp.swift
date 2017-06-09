//
//  ACLHelp.swift
//  ACLTest
//
//  Created by wenyou on 2017/6/5.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class ACLHelp {
    private static let ACL_PERM_DIR = 1 << 0
    private static let ACL_PERM_FILE = 1 << 1

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    // 打印
    func toString() -> String? {
        if let result = acl_get_file(url.path, ACL_TYPE_EXTENDED) {
            var size = acl_size(result)
            return String(utf8String: &acl_to_text(result, &size).pointee)
        }
        return nil
    }

    func checkACLPermission(userName: String, perms: [acl_perm_t]) -> Bool {
        let nameUP: UnsafePointer<Int8>? = (userName as NSString).utf8String
        guard let ump = getpwnam(nameUP) else {
            return false
        }
        return checkACLPermission(uid: ump.pointee.pw_uid, perms:perms)
    }

    func checkACLPermission(uid: UInt32, perms: [acl_perm_t]) -> Bool {
        return checkACLPermission(uid: uid, isUser: true, perms: perms)
    }

    func checkACLPermission(gid: UInt32, perms: [acl_perm_t]) -> Bool {
        return checkACLPermission(gid: gid, isUser: false, perms: perms)
    }

    // 检查权限
    private func checkACLPermission(uid: UInt32 = 0, gid: UInt32 = 0, isUser: Bool, perms: [acl_perm_t]) -> Bool {
        guard let result = acl_get_file(url.path, ACL_TYPE_EXTENDED) else {
            return false
        }

        var entryT: acl_entry_t?
        var entry_id = ACL_FIRST_ENTRY

        while acl_get_entry(result, entry_id.rawValue, &entryT) == 0 {
            entry_id = ACL_NEXT_ENTRY

            if let tagType = parseTagType(entry: entryT), tagType == ACL_EXTENDED_ALLOW { // 验证 type
                if let (isU, guid) = parseQualifier(entry: entryT), (isUser == isU && (isUser ? uid == guid : gid == guid)) { // 验证 id
                    var subFlag = true;
                    let permResult = parsePerm(entry: entryT)
                    perms.forEach({ (perm) in // 验证权限
                        subFlag = permResult.contains(perm)
                        if !subFlag {
                            return
                        }
                    })
                    if subFlag {
                        return true
                    }
                }
            }

//            NSLog("\(String(describing: parseTagType(entry: entryT)))")
//            NSLog("\(String(describing: parsePerm(entry: entryT)))")
//            NSLog("\(String(describing: parseQualifier(entry: entryT)))")
//            NSLog("\(String(describing: parseFlag(entry: entryT)))")
        }

        return false
    }

    private func outUID(pointer: UnsafeRawPointer) {
        var uuidArray = [UInt8].init(repeating: 0, count: 16) // 因为 uuid_t 和 guid_t 的size一样, so
        if arc4random_uniform(UInt32(2)) % 2 == 0 { // 两种写法都ok
            var uuidT = pointer.assumingMemoryBound(to: uuid_t.self).pointee
            memcpy(&uuidArray, &uuidT, MemoryLayout<uuid_t>.size)
        } else {
            var guidT = pointer.assumingMemoryBound(to: guid_t.self).pointee
            memcpy(&uuidArray, &guidT.g_guid, MemoryLayout<uuid_t>.size)
        }

        if let pw = getpwuuid(&uuidArray)?.pointee {
            NSLog("\(pw.pw_uid)")
        }
    }

    private func parseTagType(entry: acl_entry_t?) -> acl_tag_t? {
        var tagT: acl_tag_t = ACL_UNDEFINED_TAG
        if acl_get_tag_type(entry, &tagT) != 0 {
            return nil
        }

        return tagT
    }

    private func parsePerm(entry: acl_entry_t?) -> [acl_perm_t] {
        var perms = [acl_perm_t]()

        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            return perms
        }

        var permsetT: acl_permset_t?
        if acl_get_permset(entry, &permsetT) != 0 {
            return perms
        }

        aclPerms.forEach({ (aclPerm) in
            if acl_get_perm_np(permsetT, aclPerm.perm) == 0 {
                return
            }
            if (aclPerm.flags & (isDir.boolValue ? ACLHelp.ACL_PERM_DIR : ACLHelp.ACL_PERM_FILE)) == 0 {
                return
            }
            perms.append(aclPerm.perm)
        })

        return perms
    }

    private func parseFlag(entry: acl_entry_t?) -> [acl_flag_t] {
        var flags = [acl_flag_t]()

        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            return flags
        }

        var flagsetT: acl_flagset_t?
        if acl_get_flagset_np(UnsafeMutableRawPointer.init(entry), &flagsetT) != 0 {
            return flags
        }

        aclFlags.forEach({ (aclFlag) in
            if acl_get_flag_np(flagsetT, aclFlag.flag) == 0 {
                return
            }
            if (aclFlag.flags & (isDir.boolValue ? ACLHelp.ACL_PERM_DIR : ACLHelp.ACL_PERM_FILE)) == 0 {
                return
            }
            flags.append(aclFlag.flag)
        })

        return flags
    }

    // 此方法也可以使用 c 的方法 int mbr_uuid_to_id(const uuid_t uu, id_t* uid_or_gid, int* id_type); 来实现
    private func parseQualifier(entry: acl_entry_t?) -> (isUser: Bool, id: UInt32)? {
        guard let qualifier = acl_get_qualifier(entry) else {
            return nil
        }

        // let uuid = UUID.init(uuid: qualifier.assumingMemoryBound(to: uuid_t.self).pointee)
        var uuid = qualifier.assumingMemoryBound(to: uuid_t.self).pointee
        var uuidArray = [UInt8].init(repeating: 0, count: 16)
        memcpy(&uuidArray, &uuid, MemoryLayout<uuid_t>.size)

        if let pw = getpwuuid(&uuidArray)?.pointee {
            return (true, pw.pw_uid)
        } else if let gr = getgruuid(&uuidArray)?.pointee {
            return (false, gr.gr_gid)
        }

        return nil
    }

    private struct ACLPerm {
        let perm: acl_perm_t
        let name: String
        let flags: Int
    }

    private struct ACLFlag {
        let flag: acl_flag_t
        let name: String
        let flags: Int
    }

    private let aclPerms = [
        ACLPerm(perm: ACL_READ_DATA, name: "read", flags: ACL_PERM_FILE),
        ACLPerm(perm: ACL_LIST_DIRECTORY, name: "list", flags: ACL_PERM_DIR),
        ACLPerm(perm: ACL_WRITE_DATA, name: "write", flags: ACL_PERM_FILE),
        ACLPerm(perm: ACL_ADD_FILE, name: "add_file", flags: ACL_PERM_DIR),
        ACLPerm(perm: ACL_EXECUTE, name: "execute", flags: ACL_PERM_FILE),
        ACLPerm(perm: ACL_SEARCH, name: "search", flags: ACL_PERM_DIR),
        ACLPerm(perm: ACL_DELETE, name: "delete", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_APPEND_DATA, name: "append", flags: ACL_PERM_FILE),
        ACLPerm(perm: ACL_ADD_SUBDIRECTORY, name: "add_subdirectory", flags: ACL_PERM_DIR),
        ACLPerm(perm: ACL_DELETE_CHILD, name: "delete_child", flags: ACL_PERM_DIR),
        ACLPerm(perm: ACL_READ_ATTRIBUTES, name: "readattr", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_WRITE_ATTRIBUTES, name: "writeattr", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_READ_EXTATTRIBUTES, name: "readextattr", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_WRITE_EXTATTRIBUTES, name: "writeextattr", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_READ_SECURITY, name: "readsecurity", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_WRITE_SECURITY, name: "writesecurity", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLPerm(perm: ACL_CHANGE_OWNER, name: "chown", flags: ACL_PERM_FILE | ACL_PERM_DIR)
    ]

    private let aclFlags = [
        ACLFlag(flag: ACL_ENTRY_FILE_INHERIT, name: "file_inherit", flags: ACL_PERM_DIR),
        ACLFlag(flag: ACL_ENTRY_DIRECTORY_INHERIT, name: "directory_inherit", flags: ACL_PERM_DIR),
        ACLFlag(flag: ACL_ENTRY_LIMIT_INHERIT, name: "limit_inherit", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLFlag(flag: ACL_ENTRY_ONLY_INHERIT, name: "only_inherit", flags: ACL_PERM_DIR),
        ACLFlag(flag: ACL_FLAG_NO_INHERIT, name: "??", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLFlag(flag: ACL_ENTRY_INHERITED, name: "??", flags: ACL_PERM_FILE | ACL_PERM_DIR),
        ACLFlag(flag: ACL_FLAG_DEFER_INHERIT, name: "??", flags: ACL_PERM_FILE | ACL_PERM_DIR)
    ]

    // MARK: - 测试用, 代码正常, 但是因为权限不够无法保存. root 应该可以?
    func create() -> Bool {
        guard var result: acl_t? = acl_get_file(url.path, ACL_TYPE_EXTENDED) else {
            return false
        }
        //        var result = acl_init(1)

        var entryT: acl_entry_t?
        if acl_create_entry(&result, &entryT) != 0 {
            return false
        }

        // type
        if acl_set_tag_type(entryT, ACL_EXTENDED_ALLOW) != 0 {
            return false
        }

        // 权限
        let permUMP = UnsafeMutablePointer<acl_perm_t>.allocate(capacity: MemoryLayout<acl_perm_t>.size * 2)
        let permsetT: acl_permset_t = OpaquePointer.init(permUMP)
        if acl_add_perm(permsetT, ACL_READ_DATA) != 0 {
            return false
        }
        if acl_add_perm(permsetT, ACL_WRITE_DATA) != 0 {
            return false
        }
        if acl_set_permset(entryT, permsetT) != 0 {
            return false
        }
        permUMP.deallocate(capacity: MemoryLayout<acl_perm_t>.size * 2)

        // 用户 id
        let uidT: uid_t = 501
        var uuidArray = [UInt8].init(repeating: 0, count: MemoryLayout<uuid_t>.size / MemoryLayout<UInt8>.size)
        if mbr_uid_to_uuid(uidT, &uuidArray) != 0 { // c 函数, 此处的参数为 c 的
            return false
        }

        if arc4random_uniform(UInt32(2)) % 2 == 0 { // 两种写法都ok
            let guidUMP = UnsafeMutablePointer<uuid_t>.allocate(capacity: MemoryLayout<uuid_t>.size)
            let guidUMRP = UnsafeMutableRawPointer(guidUMP)
            memcpy(guidUMRP, &uuidArray, MemoryLayout<uuid_t>.size)
            outUID(pointer: guidUMRP)
            if acl_set_qualifier(entryT, guidUMRP) != 0 {
                return false
            }
            guidUMP.deallocate(capacity: MemoryLayout<uuid_t>.size)
        } else {
            var uuidT: uuid_t = UUID.init().uuid
            memcpy(&uuidT, &uuidArray, MemoryLayout<uuid_t>.size)
            var guidT = guid_t.init(g_guid: uuidT)
            let guidUMP: UnsafeMutablePointer<guid_t> = withUnsafeMutablePointer(to: &guidT, {return $0})
            let guidURP: UnsafeRawPointer = UnsafeRawPointer(guidUMP)
            outUID(pointer: guidURP)
            if acl_set_qualifier(entryT, guidURP) != 0 {
                return false
            }
        }

        if acl_valid(result) != 0 {
            return false
        }

        var size = acl_size(result)
        let str = String(utf8String: &acl_to_text(result, &size).pointee)
        NSLog(str!)

        if acl_set_file(url.path, ACL_TYPE_EXTENDED, result) != 0 {
            return false
        }
        
        return true
    }
}
