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

        contentViewController = CompareViewController.init()
    }
}
