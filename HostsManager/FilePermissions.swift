//
//  FilePermissions.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/9.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

typealias URLHandleBlock = (_ url: URL) -> Void

class FilePermissions {
    static let sharedInstance = FilePermissions()

    private init() {
    }

    func hostsFilePermissionsCheck() {
        let fileManager = FileManager.default
        if fileManager.isReadableFile(atPath: Constants.hostsFileURL.path) && fileManager.isWritableFile(atPath: Constants.hostsFileURL.path) {
            return
        } // 权限校验, 下面的那个 if 已经不需要了, 但是写都写了...

        let aclHelp = ACLHelp.init(url: Constants.hostsFileURL)
        if aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_READ_DATA, ACL_WRITE_DATA]) {
            return
        }

        let command = "sudo /bin/chmod +a \"user:\(NSUserName()):allow read,write\" \(Constants.hostsFileURL.path)"

        let response: NSModalResponse = {
            let alert = NSAlert.init()
            alert.alertStyle = .critical
            alert.messageText = "需要您对 hosts 文件进行权限设置"
            var text = "为了对 hosts 文件进行读写操作, 需要使用 ACL 对文件增加权限.\n\n"
            text += "命令为: \(command)\n\n"
            text += "点击 [修改权限] 会唤起 Terminal, 命令已经拷贝至剪贴板; 请粘贴命令到 Terminal, 执行并输入密码, 然后点击校验.\n"
            alert.informativeText = text
            alert.addButton(withTitle: "修改权限")
            alert.addButton(withTitle: "校验")
            alert.addButton(withTitle: "退出程序")
            return alert.runModal()
        }()

        switch response {
        case NSAlertFirstButtonReturn:
            let pasteboard = NSPasteboard.general()
            pasteboard.declareTypes([NSStringPboardType], owner: self)
            pasteboard.setString(command, forType: NSPasteboardTypeString)

            NSWorkspace.shared().launchApplication("Terminal")
            hostsFilePermissionsCheck()
        case NSAlertSecondButtonReturn:
            hostsFilePermissionsCheck()
        default:
            NSApp.terminate(self)
        }
    }

    // 执行
    func handleFile(bookmarkKey: String, newPath: String, block: URLHandleBlock) {
        var isStale = false
        if let bookmarkData = UserDefaults.standard.object(forKey: bookmarkKey) as? Data,
            let url = try! URL.init(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale),
            url.path == newPath {
            _ = url.startAccessingSecurityScopedResource()
            block(url)
            url.stopAccessingSecurityScopedResource()
        }
    }

    // 增加书签
    func addBookmark(url: URL, bookmarkKey: String) {
        let bookmarkData = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
    }

    func isBookmarkExist(bookmarkKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: bookmarkKey) != nil
    }
}
