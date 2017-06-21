//
//  CompareWindow.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/4.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit
import SnapKit

class CompareWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        self.delegate = self
        self.minSize = NSMakeSize(AppDelegate.windowSize.width, AppDelegate.windowSize.height + 22) // 22 是标题栏的高度
        contentViewController = CompareViewController.init()
    }

    var closeBlock: SimpleBlockNoneParameter? {
        get {
            if let controller = contentViewController as? CompareViewController {
                return controller.compareWindowCloseBlock
            }
            return nil
        }
        set (closeBlock) {
            if let controller = contentViewController as? CompareViewController {
                controller.compareWindowCloseBlock = closeBlock
            }
        }
    }
}

extension CompareWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) { // 点击关闭退出程序
        NSApp.terminate(notification)
    }
}
