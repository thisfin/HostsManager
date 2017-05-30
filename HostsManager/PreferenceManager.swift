//
//  PreferenceManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class PreferenceManager {
    static let sharedInstance = PreferenceManager()

    private init() {
        readPorperty()
    }

    private let hostsFileMD5Key = "hostsFileMD5"

    private var propertyInfo: PropertyInfo = {
        // 之后此处设置属性的 default value
        let propertyInfo = PropertyInfo.init()
        return propertyInfo
    }()

    var lastHostsFileMD5: String? {
        get {
            return propertyInfo.hostsFileMD5
        }
        set(lastHostsFileMD5) {
            propertyInfo.hostsFileMD5 = lastHostsFileMD5
            writeProperty()
        }
    }

    // 非沙箱 / 沙箱 路径不同
    // ~/Library/Application Support/$(PRODUCT_BUNDLE_IDENTIFIER)/Preferences/filePath.plist
    // ~/Library/Containers/$(PRODUCT_BUNDLE_IDENTIFIER)/Data/Library/Application Support/$(PRODUCT_BUNDLE_IDENTIFIER)/Preferences/filePath.plist
    let filePathDirectory: String = { // 配置文件目录
        //        NSLog(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)
        //        NSLog(FileManager.default.homeDirectoryForCurrentUser.absoluteString)
        let infoDictionary = Bundle.main.infoDictionary
        let identifier: String = infoDictionary!["CFBundleIdentifier"] as! String
        return "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)/\(identifier)/Preferences"
    }()

    // MARK: private func
    private func filePathFile() -> String  { // 配置文件地址
        return "\(filePathDirectory)/preferences.plist"
    }

    private func readPorperty() {
        if FileManager.default.fileExists(atPath: filePathFile()), let dict = NSDictionary(contentsOfFile: filePathFile()) {
            let d: [String : String] = dict as! [String : String]
            if let hostsFileMD5 = d[hostsFileMD5Key] {
                propertyInfo.hostsFileMD5 = hostsFileMD5
            }
        }
    }

    private func writeProperty() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePathFile()) { // 建目录
            if !fileManager.fileExists(atPath: filePathDirectory) {
                try! fileManager.createDirectory(atPath: filePathDirectory, withIntermediateDirectories: true)
            }
            fileManager.createFile(atPath: filePathFile(), contents: nil)
        }
        var dict: [String: String] = [:]
        if let md5 = propertyInfo.hostsFileMD5 {
            dict[hostsFileMD5Key] = md5
        }
        (dict as NSDictionary).write(toFile: filePathFile(), atomically: false)
    }
}

struct PropertyInfo {
    var hostsFileMD5: String?
}
