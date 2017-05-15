//
//  HostsFileManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/2.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class HostsFileManager: NSObject {
    static let sharedInstance = {
        return HostsFileManager()
    }()

    override private init() {
        super.init()
    }

    private let url = URL.init(fileURLWithPath: NSOpenStepRootDirectory() + "etc/hosts1")

    private var fileMD5: String {
        get {
            // http://stackoverflow.com/questions/42935148/swift-calculate-md5-checksum-for-large-files
            let file = try! FileHandle.init(forReadingFrom: url)

            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)

            let bufferSize = 1024 * 1024
            while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
                data.withUnsafeBytes({ (contentType) -> Void in
                    _ = CC_MD5_Update(&context, contentType, CC_LONG(data.count))
                })
            }

            var digest = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
            digest.withUnsafeMutableBytes { (contentType) -> Void in
                _ = CC_MD5_Final(contentType, &context)
            }

            let hexDigest = digest.map({ (uInt8) -> String in
                return String.init(format: "%02hhx", uInt8)
            }).joined()

            return hexDigest
        }
    }

    // 验证 hosts 文件的状态
    func checkHostsFile() -> FileState {

        return .FileChange
        if let oldMD5 = PreferenceManager.sharedInstance.lastHostsFileMD5 {
            if oldMD5 == fileMD5 {
                return .FileUnchange
            }
            return .FileChange
        }
        return .NeverInit
    }

    func writeContentToFile(content: Array<Group>) {
        // 权限验证

        var fileContent = String.init()
        content.forEach { (group) in
            if group.selected {
                fileContent.append("# _wywywy_ \(group.name!)\n")
                fileContent.append("\(group.content)\n")
            }
        }
        if fileContent.characters.count > 0 {
            try! fileContent.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    // 返回解析后的 hosts 对象, 如果之前没有被本程序写过, 则读取文件出为一个单一 group, 该 group 的 name 为空
    func readContentFromFile() -> Array<Group> {
        let fileContent = try! String.init(contentsOfFile: url.path, encoding: .utf8)
        let regexPrefix = "# _wywywy_ "
        let regex = try! NSRegularExpression.init(pattern: "\(regexPrefix).*\n", options: []) // group 分隔符

        var lastLocation: Int = 0
        var groupTemp: Group?
        var groups: Array<Group> = Array.init()
        regex.enumerateMatches(in: fileContent, options: [], range: NSRange.init(location: 0, length: fileContent.characters.count)) {
            (textCheckingResult, matchingFlags, b) in
            let range = (textCheckingResult?.range)!

            if range.location > lastLocation && lastLocation != 0 {
                let value = (fileContent as NSString).substring(with: NSMakeRange(lastLocation, range.location - lastLocation))
                groupTemp?.content = replaceReturn(content: value)
            }

            let name = (fileContent as NSString).substring(with: NSMakeRange(range.location + regexPrefix.characters.count, range.length - regexPrefix.characters.count)).replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
            groupTemp = Group.init()
            groupTemp?.name = name
            groupTemp?.selected = true
            groups.append(groupTemp!)

            lastLocation = range.location + range.length
        }

        if fileContent.characters.count > lastLocation {
            let value = (fileContent as NSString).substring(with: NSMakeRange(lastLocation, fileContent.characters.count - lastLocation))
            if groupTemp == nil {
                groupTemp = Group.init()
                groupTemp?.selected = true
                groups.append(groupTemp!)
            }
            groupTemp?.content = replaceReturn(content: value)
        }

        return groups
    }

    // 去掉头尾的换行符
    func replaceReturn(content: String) -> String {
        var value = content
        let beginRegex = try! NSRegularExpression.init(pattern: "(\r\n)+|(\n)+", options: []) // 行首换行
        let endRegex = try! NSRegularExpression.init(pattern: "(\r\n)+|(\n)+$", options: []) // 行末换行
        // 去掉头部的换行符
        if case let result = beginRegex.firstMatch(in: value, options: [], range: NSMakeRange(0, value.characters.count)), result?.range.location == 0 {
            value = (value as NSString).replacingCharacters(in: (result?.range)!, with: "")
        }
        // 去掉尾部的换行符
        endRegex.enumerateMatches(in: value, options: [], range: NSMakeRange(0, value.characters.count), using: { (textCheckingResult, matchingFlags, b) in
            if case let result = textCheckingResult?.range, (result?.location)! + (result?.length)! == value.characters.count {
                value = (value as NSString).replacingCharacters(in: result!, with: "")
            }
        })
        return value
    }

    public enum FileState {
        case NeverInit      // 未初始化过, 程序第一次运行
        case FileChange     // 用户未通过此程序对 hosts 文件进行了修改
        case FileUnchange   // 文件正常
    }

//    public struct FileState: RawRepresentable {
//        var rawValue: UInt
//        init(rawValue: UInt) {
//            self.rawValue = rawValue
//        }
//
//        public static let neverInit = FileState.init(rawValue: 0)      // 未初始化过, 程序第一次运行
//        public static let fileChanage = FileState.init(rawValue: 1)    // 用户未通过此程序对 hosts 文件进行了修改
//        public static let fileUnchange = FileState.init(rawValue: 2)   // 文件正常
//    }
}
