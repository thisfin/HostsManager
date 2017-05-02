//
//  HostsFileManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/2.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class HostsFileManager {
    private let url = URL.init(fileURLWithPath: NSOpenStepRootDirectory() + "etc/hosts")

    var fileMD5: String {
        get {
            // http://stackoverflow.com/questions/42935148/swift-calculate-md5-checksum-for-large-files
            let file = try! FileHandle.init(forReadingFrom: url)

            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)

            let bufferSize = 1024 * 1024
            // 语法有些奇怪...
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

    func writeContentToFile(content: Array<Group>) {
        // 权限验证

        content.forEach { (group) in
            if group.selected {

            }
        }
    }

    func readContentFromFile() -> Array<Group> {
        return Array.init()
    }
}
