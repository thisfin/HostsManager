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
        }(){
        didSet {
            // TODO: 设置属性 如果struct的属性修改后也可以触发这个方法的话(struct是值类型, 估计可以, 待测试下), 将外露的lastmd5属性可以干掉
        }
    }

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