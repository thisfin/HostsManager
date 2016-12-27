//
//  EditorViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController {
    static let viewWidth = CGFloat(400)
    static let viewHeight = CGFloat(400)

    override func loadView() {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
        view.wantsLayer = true
        view.layer?.borderWidth = 2
        view.layer?.borderColor = NSColor.red.cgColor
        self.view = view

//        var toolbar: NSToolbar = NSToolbar.init()
    }
}
