//
//  PreferenceManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class PreferenceManager {
    static let sharedInstance = PreferenceManager()

    private init() {
        readPorperty()
    }

    private let hostsFileMD5Key = "hostsFileMD5"
    private let startupLoginKey = "startupLogin"
    private let dockIconShowKey = "dockIconShow"

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
        let identifier = infoDictionary!["CFBundleIdentifier"] as! String
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
            if let d = dict as? [String : String] {
                propertyInfo.hostsFileMD5 = d[hostsFileMD5Key]
                if let startupLoginString = d[startupLoginKey], let startupLoginBool = Bool.init(startupLoginString) {
                    propertyInfo.startupLogin = startupLoginBool
                }
                if let dockIconShowString = d[dockIconShowKey], let dockIconShowBool = Bool.init(dockIconShowString) {
                    propertyInfo.dockIconShow = dockIconShowBool
                }
            }
        }
    }

    private func writeProperty() {
        var dict: [String: String] = [:]
        if let md5 = propertyInfo.hostsFileMD5 {
            dict[hostsFileMD5Key] = md5
        }
        dict[startupLoginKey] = propertyInfo.startupLogin.description
        dict[dockIconShowKey] = propertyInfo.dockIconShow.description
        (dict as NSDictionary).write(toFile: filePathFile(), atomically: false)
    }
}

struct PropertyInfo {
    var hostsFileMD5: String?
    var startupLogin: Bool = false
    var dockIconShow: Bool = true
}
