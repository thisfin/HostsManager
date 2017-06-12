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

    var propertyInfo: PropertyInfo = {
        // 之后此处设置属性的 default value
        let propertyInfo = PropertyInfo.init()
        return propertyInfo
        }() {
        didSet {
            // PropertyInfo 是 struct, 所以属性修改的时候 didSet 也会调用
            writeProperty()
        }
    }

    // 非沙箱 / 沙箱 路径不同
    //                                                      ~/Library/Application Support/$(PRODUCT_BUNDLE_IDENTIFIER)/Preferences/filePath.plist
    // ~/Library/Containers/$(PRODUCT_BUNDLE_IDENTIFIER)/Data/Library/Application Support/$(PRODUCT_BUNDLE_IDENTIFIER)/Preferences/filePath.plist
    let preferencesDirectoryPath: String = { // 配置文件目录
        // NSLog(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)
        // NSLog(FileManager.default.homeDirectoryForCurrentUser.absoluteString)
        let infoDictionary = Bundle.main.infoDictionary
        let identifier: String = infoDictionary!["CFBundleIdentifier"] as! String
        let pathString = "\(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)/\(identifier)/Preferences"
        if !FileManager.default.fileExists(atPath: pathString) {
            try! FileManager.default.createDirectory(atPath: pathString, withIntermediateDirectories: true)
        }
        return pathString
    }()

    // MARK: private func
    private func filePathFile() -> String  { // 配置文件地址
        return "\(preferencesDirectoryPath)/preferences.plist"
    }

    private func readPorperty() {
        if FileManager.default.fileExists(atPath: filePathFile()), let dict = NSDictionary(contentsOfFile: filePathFile()) {
            let d: [String : String] = dict as! [String : String]
            propertyInfo.hostsFileMD5 = d[hostsFileMD5Key]
        }
    }

    private func writeProperty() {
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
