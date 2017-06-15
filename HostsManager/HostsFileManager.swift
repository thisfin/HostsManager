//
//  HostsFileManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/2.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation
import AppKit

class HostsFileManager {
    static let sharedInstance = HostsFileManager()

    private init() {
    }

    // hosts 文件的md5
    // http://stackoverflow.com/questions/42935148/swift-calculate-md5-checksum-for-large-files
    func fileMD5() -> String {
        let file = try! FileHandle.init(forReadingFrom: Constants.hostsFileURL)
        defer {
            file.closeFile()
        }

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

    // 验证 hosts 文件的状态
    func checkHostsFile() -> FileState {
        if let oldMD5 = PreferenceManager.sharedInstance.propertyInfo.hostsFileMD5 {
            if oldMD5 == fileMD5() {
                return .FileUnchange
            }
            return .FileChange
        }
        return .NeverInit
    }

    func writeContentToFile(content: [Group]) {
        var fileContent = String.init()
        content.forEach { (group) in
            if group.selected {
                fileContent.append("\(Constants.hostsFileGroupPrefix)\(group.name!)\n")
                fileContent.append("\(group.content)\n")
            }
        }
        if fileContent.characters.count > 0 {
//            var isStale: Bool = false
//            if let bookmarkData = UserDefaults.standard.object(forKey: Constants.userDefaultsHostsBookmarkKey),
//                bookmarkData is Data,
//                let url = try! URL.init(resolvingBookmarkData: bookmarkData as! Data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale) {
//                NSLog("isStale \(isStale)")
//                NSLog("\(url.startAccessingSecurityScopedResource())")
//                try! fileContent.write(to: url, atomically: false, encoding: .utf8)
//                url.stopAccessingSecurityScopedResource()
//            }
            try! fileContent.write(to: Constants.hostsFileURL, atomically: false, encoding: .utf8)
        }
        PreferenceManager.sharedInstance.propertyInfo.hostsFileMD5 = fileMD5()
    }

    // 返回解析后的 hosts 对象, 如果之前没有被本程序写过, 则读取文件出为一个单一 group, 该 group 的 name 为空
    func readContentFromFile() -> [Group] {
//        self.url.startAccessingSecurityScopedResource()
        let fileContent = try! String.init(contentsOfFile: Constants.hostsFileURL.path, encoding: .utf8)
        let regexPrefix = Constants.hostsFileGroupPrefix
        let regex = try! NSRegularExpression.init(pattern: "\(regexPrefix).*\n", options: []) // group 分隔符

        var lastLocation: Int = 0
        var groupTemp: Group?
        var groups = [Group]()
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

    func readContentStringFromFile() -> String? {
        let data = try! Data.init(contentsOf: Constants.hostsFileURL)
        if let string = String.init(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }

    // 去掉头尾的换行符
    func replaceReturn(content: String) -> String {
        var value = content
        let beginRegex = try! NSRegularExpression.init(pattern: "(\r\n)+|(\n)+", options: []) // 行首换行
        let endRegex = try! NSRegularExpression.init(pattern: "(\r\n)+|(\n)+$", options: []) // 行末换行
        // 去掉头部的换行符
        if let result = beginRegex.firstMatch(in: value, options: [], range: NSMakeRange(0, value.characters.count)), result.range.location == 0 {
            value = (value as NSString).replacingCharacters(in: result.range, with: "")
        }
        // 去掉尾部的换行符
        endRegex.enumerateMatches(in: value, options: [], range: NSMakeRange(0, value.characters.count), using: { (textCheckingResult, matchingFlags, b) in
            if let result = textCheckingResult?.range, result.location + result.length == value.characters.count {
                value = (value as NSString).replacingCharacters(in: result, with: "")
            }
        })
        return value
    }

    public enum FileState {
        case NeverInit      // 未初始化过, 程序第一次运行
        case FileChange     // 用户未通过此程序对 hosts 文件进行了修改
        case FileUnchange   // 文件正常
    }

    // 保存 hosts 文件的md5
    func saveMD5() {
        PreferenceManager.sharedInstance.propertyInfo.hostsFileMD5 = fileMD5()
    }
}
