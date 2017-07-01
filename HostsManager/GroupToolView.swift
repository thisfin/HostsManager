//
//  GroupToolView.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/4.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit
import WYKit

class GroupToolView: NSView {
    let toolMenu: ToolMenu

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(frame frameRect: NSRect) {
        toolMenu = ToolMenu()

        super.init(frame: frameRect)

        wantsLayer = true
        layer?.addBorder(edges: [.minX, .maxX, .minY], color: Constants.colorTableBorder, thickness: 1)
        initSubview()

        toolMenu.handle = self
    }

    var addGroupBlock: SimpleBlockNoneParameter?
    var removeGroupBlock: SimpleBlockNoneParameter?
    var saveBlock: SimpleBlockNoneParameter?
    var revertBlock: SimpleBlockNoneParameter?
    var exportConfigBlock: SimpleBlockNoneParameter?
    var importConfigBlock: SimpleBlockNoneParameter?

    private func initSubview() {
        let addButton = NSButton(image: NSImage(named: NSImageNameAddTemplate)!,
                                 target: self,
                                 action: #selector(GroupToolView.addButtonClicked(_:)))
        addButton.setButtonType(.momentaryPushIn)
        addButton.bezelStyle = .smallSquare
        addButton.isBordered = false
        addButton.wantsLayer = true
        addButton.layer?.addBorder(edges: [.maxX], color: Constants.colorTableBorder, thickness: 1)
        addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(35)
        }

        let removeButton = NSButton(image: NSImage(named: NSImageNameRemoveTemplate)!,
                                    target: self,
                                    action: #selector(GroupToolView.removeButtonClicked(_:)))
        removeButton.setButtonType(.momentaryPushIn)
        removeButton.bezelStyle = .smallSquare
        removeButton.isBordered = false
        removeButton.wantsLayer = true
        removeButton.layer?.addBorder(edges: [.maxX], color: Constants.colorTableBorder, thickness: 1)
        addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(addButton.snp.right)
            make.width.equalTo(addButton)
        }

        let settingButton = NSButton(title: Constants.iconfontCog,
                                     target: self,
                                     action: #selector(GroupToolView.settingButtonClicked(_:)))
        settingButton.font = WYIconfont.fontOfSize(14)
        settingButton.setButtonType(.momentaryPushIn)
        settingButton.bezelStyle = .smallSquare
        settingButton.isBordered = false
        settingButton.wantsLayer = true
        settingButton.layer?.addBorder(edges: [.maxX], color: Constants.colorTableBorder, thickness: 1)
        addSubview(settingButton)
        settingButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(removeButton.snp.right)
            make.width.equalTo(addButton)
        }

        let saveButton = NSButton(title: "应用更改",
                                    target: self,
                                    action: #selector(GroupToolView.saveButtonClicked(_:)))
        saveButton.setButtonType(.momentaryPushIn)
        saveButton.bezelStyle = .smallSquare
        saveButton.isBordered = false
        addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(settingButton.snp.right)
            make.right.equalToSuperview()
        }
    }

    func addButtonClicked(_ sender: NSButton) {
        if let block = addGroupBlock {
            block()
        }
    }

    func removeButtonClicked(_ sender: NSButton) {
        if let block = removeGroupBlock {
            block()
        }
    }

    func settingButtonClicked(_ sender: NSButton) {
        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(toolMenu, with: event, for: sender)
        }
    }

    func saveButtonClicked(_ sender: NSButton) {
        if let block = saveBlock {
            block()
        }
    }
}
