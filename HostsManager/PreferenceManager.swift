//
//  PreferenceManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class PreferenceManager: NSObject {
    private let hostsFileMD5Key = "hostsFileMD5"

    static let sharedInstance = {
        return PreferenceManager()
    }()

    override private init() {
        super.init()

        readPorperty()
    }

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

    // ~/Library/Application Support/$(PRODUCT_BUNDLE_IDENTIFIER)/Preferences/filePath.plist
    private let filePathDirectory: String = { // 配置文件目录
        //        NSLog(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)
        //        NSLog(FileManager.default.homeDirectoryForCurrentUser.absoluteString)
        let infoDictionary = Bundle.main.infoDictionary
        let identifier: String = infoDictionary!["CFBundleIdentifier"] as! String
        return "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)/\(identifier)/Preferences"
    }()

    private func filePathFile() -> String  { // 配置文件地址
        return "\(filePathDirectory)/preferences.plist"
    }

    private func readPorperty() {
        if FileManager.default.fileExists(atPath: filePathFile()) {
            if let dict = NSDictionary(contentsOfFile: filePathFile()) {
                let d: [String : String] = dict as! [String : String]
                if let hostsFileMD5 = d[hostsFileMD5Key] {
                    propertyInfo.hostsFileMD5 = hostsFileMD5
                }
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
