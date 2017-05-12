//
//  WYHelp.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class WYHelp {
    static func alert(title: String, message: String) {
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.beginSheetModal(for: NSApp.mainWindow!, completionHandler: nil)
    }
}
