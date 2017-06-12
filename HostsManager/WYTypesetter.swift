//
//  WYTypesetter.swift
//  RichTextView
//
//  Created by wenyou on 2017/4/13.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class WYTypesetter: NSATSTypesetter {
    // 重写此方法用来固定行高, 因为英文和中文的行高不同
    override func willSetLineFragmentRect(_ lineRect: UnsafeMutablePointer<NSRect>, forGlyphRange glyphRange: NSRange, usedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>) {
        let font = NSFont.userFixedPitchFont(ofSize: Constants.hostInfoFontSize)
        let lineHeight = layoutManager?.defaultLineHeight(for: font!)

        lineRect.pointee.size.height = lineHeight!
        usedRect.pointee.size.height = lineHeight!
        baselineOffset.pointee = (layoutManager?.defaultBaselineOffset(for: font!))!
    }
}
