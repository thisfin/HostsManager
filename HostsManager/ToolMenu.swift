//
//  ToolMenu.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/18.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class ToolMenu: NSMenu {
    var testMenuItem: NSMenuItem!
    weak var handle: GroupToolView?

    init() {
        super.init(title: "")

        initSubMenuItem()
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubMenuItem() {
        let revertMenuItem = NSMenuItem(title: "回退到上次保存的记录", action: #selector(ToolMenu.revertClicked(_:)), keyEquivalent: "")
        revertMenuItem.target = self
        addItem(revertMenuItem)

        addItem(NSMenuItem.separator())

        let exportConfigMenuItem = NSMenuItem(title: "导出 hosts 设置", action: #selector(ToolMenu.exportConfigClicked(_:)), keyEquivalent: "")
        exportConfigMenuItem.target = self
        addItem(exportConfigMenuItem)

        let importConfigMenuItem = NSMenuItem(title: "导入 hosts 设置", action: #selector(ToolMenu.importConfigClicked(_:)), keyEquivalent: "")
        importConfigMenuItem.target = self
        addItem(importConfigMenuItem)
    }

    // MARK: - action
    func revertClicked(_ sender: NSMenuItem) {
        if let block = handle?.revertBlock {
            block()
        }
    }

    func exportConfigClicked(_ sender: NSMenuItem) {
        if let block = handle?.exportConfigBlock {
            block()
        }
    }

    func importConfigClicked(_ sender: NSMenuItem) {
        if let block = handle?.importConfigBlock {
            block()
        }
    }
}
