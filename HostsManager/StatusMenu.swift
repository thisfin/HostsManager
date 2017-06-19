//
//  WYMenu.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

class StatusMenu: NSMenu, NSMenuDelegate {
    var testMenuItem: NSMenuItem!

    var popover: NSPopover = {
        let popover = NSPopover.init()
        popover.contentViewController = SourceViewController()
        return popover
    }()

    init() {
        super.init(title: "")

        delegate = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - private
    func addDefaultItem() {
        addItem(NSMenuItem.separator())
        addItem({
            let menuItem = NSMenuItem.init(title: "Preferences...", action: #selector(StatusMenu.settingClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())

        addItem(NSMenuItem.separator())
        addItem({
            let menuItem = NSMenuItem.init(title: "About HostsManager", action: #selector(StatusMenu.aboutClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())
        addItem({
            let menuItem = NSMenuItem.init(title: "Quit HostsManager", action: #selector(StatusMenu.quitClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())
    }

    // MARK: - action
    func aboutClicked(_ sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(self)
    }

    func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

    func settingClicked(_ sender: NSMenuItem) {
        // TODO: - 唤起 window
    }

    func groupClicked(_ sender: NSMenuItem) {
        let dataManager = HostDataManager.sharedInstance
        let group = dataManager.groups[sender.tag]
        group.selected = !group.selected
        dataManager.updateGroupData()
        HostsFileManager.sharedInstance.writeContentToFile(content: dataManager.groups)
        // TODO: - 消息更新 window
    }

    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        removeAllItems()

        let dataManager = HostDataManager.sharedInstance
        for index in 0 ..< dataManager.groups.count {
            let group = dataManager.groups[index]
            addItem({
                let menuItem = NSMenuItem.init(title: group.name!, action: #selector(StatusMenu.groupClicked(_:)), keyEquivalent: "")
                menuItem.tag = index
                menuItem.target = self
                if group.selected {
                    menuItem.state = NSOnState
                }
                return menuItem
                }())
        }

        addDefaultItem()
    }

    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let menuItem = item, menuItem.tag >= 0 {
            // TODO:
            popover.show(relativeTo: (menuItem.view?.bounds)!, of: menuItem.view!, preferredEdge: .maxY)
        }
    }
}
