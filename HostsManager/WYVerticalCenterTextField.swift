//
//  WYVerticalCenterTextField.swift
//  EmptyProject
//
//  Created by wenyou on 2017/6/16.
//  Copyright © 2017年 fin. All rights reserved.
//

import AppKit

// https://stackoverflow.com/questions/11775128/set-text-vertical-center-in-nstextfield
// NSTextField().cell = WYVerticalCenterTextFieldCell()
class WYVerticalCenterTextFieldCell: NSTextFieldCell {
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleRect = super.titleRect(forBounds: rect)
        let minimumHeight = cellSize(forBounds: rect).height
        titleRect.origin.y += (titleRect.height - minimumHeight) / 2
        titleRect.size.height = minimumHeight
        return titleRect
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
    }

    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: titleRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
}
