//
//  WYHelp.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class WYHelp {
    static func alertInformational(title: String, message: String) {
        alert(title: title, message: message, style: .informational)
    }

    static func alertWarning(title: String, message: String) {
        alert(title: title, message: message, style: .warning)
    }

    private static func alert(title: String, message: String, style: NSAlertStyle) {
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.beginSheetModal(for: NSApp.mainWindow!, completionHandler: nil)
    }

    static func authenticationHostsFile() {
        let command = "sudo chmod 777 \(HostsFileManager.sharedInstance.url.path)"
        _ = WYAuthentication.sharedInstance.authenticate(command)
    }

    static func deauthenticationHostFile() {
        _ = WYAuthentication.sharedInstance.deauthenticate()
    }
}
