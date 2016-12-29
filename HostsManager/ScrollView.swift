//
//  ScrollView.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/29.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class ScrollView: NSScrollView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

//        NSGraphicsContext.saveGraphicsState()
//        NSColor.red.set()
//        let bounds = self.bounds
//        let innerRect = NSInsetRect(bounds, 2, 2)
//        let outerRect = NSMakeRect(bounds.origin.x - 2, bounds.origin.y - 2, bounds.size.width + 4, bounds.size.height + 4)
//        let clipPath = NSBezierPath(rect: outerRect)
//        clipPath.append(NSBezierPath(rect: innerRect))
//        clipPath.windingRule = .evenOddWindingRule
//        clipPath.setClip()
//        NSBezierPath(rect: outerRect).fill()
//        NSGraphicsContext.restoreGraphicsState()
    }
}
