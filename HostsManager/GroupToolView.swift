//
//  GroupToolView.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/4.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class GroupToolView: NSView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initSubview()
        wantsLayer = true
        layer?.backgroundColor = NSColor.yellow.cgColor
    }

    private func initSubview() {
        let addButton = NSButton.init(title: "+", target: self, action: #selector(GroupToolView.addButtonClicked(_:)))
        addButton.frame = NSMakeRect(0, 0, frame.width / 4, frame.height)
        addButton.font = WYIconfont.fontOfSize(14)
addButton.font = NSFont.systemFont(ofSize: 16)
        addButton.alignment = .center

//        addButton.layer?.borderWidth = 1
//        addButton.layer?.borderColor = Constants.colorTableBorder.cgColor
//        addButton.wantsLayer = false
        addButton.layer?.backgroundColor = NSColor.blue.cgColor
        addButton.setButtonType(.momentaryPushIn)
        addButton.bezelStyle = .smallSquare
        addButton.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        addButton.isBordered = true
        addSubview(addButton)
    }

    func addButtonClicked(_ sender: NSButton) {
        NSLog("addbutton")
    }
}
