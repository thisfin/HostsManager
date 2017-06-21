//
//  WYMenu.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

class StatusMenu: NSMenu, NSMenuDelegate {
    weak var statusItem: NSStatusItem?

    var popover: NSPopover = {
        let popover = NSPopover.init()
        popover.contentViewController = {
            let controller = PopoverViewController()
            controller.popover = popover
            return controller
            }()
        return popover
    }()

    init(statusItem: NSStatusItem?) {
        super.init(title: "")

        self.statusItem = statusItem
        delegate = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - private
    func addDefaultItem() {
        addItem(NSMenuItem.separator())
        addItem({
            let menuItem = NSMenuItem.init(title: "Edit Hosts", action: #selector(StatusMenu.editClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())
        addItem({
            let menuItem = NSMenuItem.init(title: "Preferences...", action: #selector(StatusMenu.settingClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())

        addItem(NSMenuItem.separator())
        addItem({
            let menuItem = NSMenuItem.init(title: "About \(ProcessInfo.processInfo.processName)", action: #selector(StatusMenu.aboutClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())
        addItem({
            let menuItem = NSMenuItem.init(title: "Quit \(ProcessInfo.processInfo.processName)", action: #selector(StatusMenu.quitClicked(_:)), keyEquivalent: "")
            menuItem.target = self
            return menuItem
            }())
    }

    // MARK: - action
    func aboutClicked(_ sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(self)
    }

    func quitClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    func editClicked(_ sender: NSMenuItem) {
        NSRunningApplication.current().activate(options: [.activateIgnoringOtherApps])
        NSApp.windows.forEach { (window) in
            if let win = window as? SettingWindow {
                win.toolbarItemSelected(identifier: .edit)
                win.center()
                win.makeKeyAndOrderFront(self)
                return
            }
        }
    }

    func settingClicked(_ sender: NSMenuItem) { // 唤起 window 切换至 setting controller
        NSRunningApplication.current().activate(options: [.activateIgnoringOtherApps])
        NSApp.windows.forEach { (window) in
            if let win = window as? SettingWindow {
                win.toolbarItemSelected(identifier: .setting)
                win.center()
                win.makeKeyAndOrderFront(self)
                return
            }
        }
    }

    func groupClicked(_ sender: NSMenuItem) {
        let dataManager = HostDataManager.sharedInstance
        let group = dataManager.groups[sender.tag - 100]
        group.selected = !group.selected
        dataManager.updateGroupData()
        HostsFileManager.sharedInstance.writeContentToFile(content: dataManager.groups)
        // TODO: - 消息更新 window
    }

    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) { // 开启时初始化 menu
        removeAllItems()

        let dataManager = HostDataManager.sharedInstance
        for index in 0 ..< dataManager.groups.count {
            let group = dataManager.groups[index]
            addItem({
                let menuItem = NSMenuItem.init(title: group.name!, action: #selector(StatusMenu.groupClicked(_:)), keyEquivalent: "")
                menuItem.tag = index + 100
                menuItem.target = self
                if group.selected {
                    menuItem.state = NSOnState
                }
                return menuItem
                }())
        }

        addDefaultItem()
    }

    func menuDidClose(_ menu: NSMenu) { // 关闭时关闭浮层
        if popover.isShown {
            popover.performClose(nil)
        }
    }

    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) { // 鼠标浮动变更时改变浮层显示内容
        if let menuItem = item, menuItem.tag >= 100, let button = statusItem?.button {
            let group = HostDataManager.sharedInstance.groups[(menuItem.tag - 100)]
            var string = ""
            group.hosts.forEach({ (host) in
                string.append((string.characters.count == 0 ? "" : "\n") +  "\(host.ip) \(host.domain)")
            })

            if !popover.isShown {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minX)
            }
            // 此行代码放在下边是因为第一次时, controller viewWillApper 之前调用 fittingSize 返回结果不对
            if let controller = popover.contentViewController as? PopoverViewController {
                controller.setText(string: string)
            }
        } else {
            if popover.isShown {
                popover.performClose(nil)
            }
        }
    }
}
