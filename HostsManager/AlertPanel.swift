//
//  AlertPanel.swift
//  HostsManager
//
//  Created by wenyou on 2017/7/1.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit
import SnapKit

class AlertPanel  {
    class func show(_ content: String, fontSize: CGFloat = 32) {
        let font = NSFont.systemFont(ofSize: fontSize)
        let size = (content as NSString).size(withAttributes: [NSFontAttributeName: font])
        let panel = NSPanel.init(contentRect: NSMakeRect(0, 0, size.width + 100, size.height + 40), styleMask: [.borderless, .hudWindow], backing: .buffered, defer: true)
        let textField = NSTextField.init(frame: panel.contentLayoutRect)
        textField.cell = WYVerticalCenterTextFieldCell()
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.alignment = .center
        textField.textColor = .white
        textField.font = font
        textField.stringValue = content
        if let contentView = panel.contentView {
            contentView.addSubview(textField)
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = panel.backgroundColor.cgColor
            contentView.layer?.cornerRadius = 5
        }
        panel.backgroundColor = .clear
        panel.center()
        panel.orderFront(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: {
            panel.orderOut(self)
            panel.close()
        })
    }
}
