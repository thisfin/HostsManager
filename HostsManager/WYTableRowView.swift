//
//  WYTabRowView.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/23.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class WYTableRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) { // 自定义选择样式
        if selectionHighlightStyle != .none {
//            let selectionRect = NSInsetRect(bounds, 2.5, 2.5)
//            NSColor.init(calibratedWhite: 0.65, alpha: 1).setStroke()
//            NSColor.init(calibratedWhite: 0.82, alpha: 1).setFill()
//            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
//            selectionPath.fill()
//            selectionPath.stroke()
            NSColor.gridColor.set()
            NSRectFill(dirtyRect)
        }
    }
}
