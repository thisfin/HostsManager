//
//  WYHelp.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class WYHelp {
    static func alertInformational(title: String, message: String, window: NSWindow? = nil, completionHandler handler: ((NSModalResponse) -> Swift.Void)? = nil) {
        alert(title: title, message: message, style: .informational, window: window, completionHandler: handler)
    }

    static func alertWarning(title: String, message: String, window: NSWindow? = nil, completionHandler handler: ((NSModalResponse) -> Swift.Void)? = nil) {
        alert(title: title, message: message, style: .warning, window: window, completionHandler: handler)
    }

    private static func alert(title: String, message: String, style: NSAlertStyle, window: NSWindow? = nil, completionHandler handler: ((NSModalResponse) -> Swift.Void)? = nil) {
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        let win = window != nil ? window : NSApp.mainWindow
        alert.beginSheetModal(for: win!, completionHandler: handler)
    }
}
