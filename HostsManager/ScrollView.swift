//
//  ScrollView.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/29.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

class ScrollView: NSScrollView {
    override func draw(_ dirtyRect: NSRect) { // 不重写不出边框...
        super.draw(dirtyRect)
    }
}
