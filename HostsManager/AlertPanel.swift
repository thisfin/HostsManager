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
    static func show(_ content: String, fontSize: CGFloat = 32) {
        let font = NSFont.systemFont(ofSize: fontSize)
        let size = (content as NSString).size(withAttributes: [NSFontAttributeName: font])
        let panel = NSPanel(contentRect: NSMakeRect(0, 0, size.width + 100, size.height + 40), styleMask: [.borderless, .hudWindow], backing: .buffered, defer: true)
        let textField = NSTextField.init(frame: panel.contentLayoutRect)
        textField.cell = WYVerticalCenterTextFieldCell()
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.alignment = .center
        textField.textColor = .white
        textField.font = font
        textField.stringValue = content
        if let contentView = panel.contentView { // 此处做颜色和圆角的处理
            contentView.addSubview(textField)
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 5
            contentView.layer?.backgroundColor = panel.backgroundColor.cgColor // 使用默认 hudWindow 的颜色
            panel.backgroundColor = .clear
        }
        panel.center()
        panel.orderFront(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: { // 自动关闭
            panel.orderOut(self)
            panel.close()
        })
    }
}
