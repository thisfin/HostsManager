//
//  CompareWindow.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/4.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit
import SnapKit

class CompareWindow: NSWindow, NSWindowDelegate {
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        self.delegate = self
        contentViewController = CompareViewController.init()
    }

    var closeBlock: SimpleBlockNoneParameter? {
        get {
            if case let controller = contentViewController, controller is CompareViewController {
                return (controller as! CompareViewController).compareWindowCloseBlock
            }
            return nil
        }
        set (closeBlock) {
            if case let controller = contentViewController, controller is CompareViewController {
                (controller as! CompareViewController).compareWindowCloseBlock = closeBlock
            }
        }
    }

    //MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) { // 点击关闭退出程序
        NSApp.terminate(notification)
    }
}
