//
//  SettingWindow.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/27.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class SettingWindow: NSWindow, NSToolbarDelegate {
    let toolbarItemInfos: [ToolbarItemInfo] = [
        ToolbarItemInfo(title: "编辑",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontEdit, backgroundColor: .clear, iconColor: .black, size: CGSize(width: 40, height:40)),
                        viewController: EditorViewController(),
                        identifier: "a"),
        ToolbarItemInfo(title: "查看源文件",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontText, backgroundColor: .clear, iconColor: .black, size: CGSize(width: 40, height:40)),
                        viewController: SourceViewController(),
                        identifier: "b"),
        ToolbarItemInfo(title: "设置",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontCog, backgroundColor: .clear, iconColor: .black, size: CGSize(width: 40, height:40)),
                        viewController: SettingViewController(),
                        identifier: "c")]

    var nowShowItemIdentifier: String = ""

    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        // 设置toolbar
        toolbar = {
            let toolbar = NSToolbar(identifier: "WYToolbarIdentifier") // 默认构造函数有问题!!!
            toolbar.allowsUserCustomization = true
            toolbar.autosavesConfiguration = false
            toolbar.displayMode = .iconAndLabel
            toolbar.sizeMode = .default
            toolbar.delegate = self
            return toolbar
        }()
        // 设置默认值
        toolbar?.selectedItemIdentifier = toolbarItemInfos[0].identifier
        itemSelected(selectedItemIdentifier: toolbarItemInfos[0].identifier)
    }

    // MARK: - NSToolbarDelegate
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var toolbarItemInfo: ToolbarItemInfo!
        for info in toolbarItemInfos {
            if info.identifier == itemIdentifier {
                toolbarItemInfo = info
            }
        }
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.minSize = CGSize(width: 30, height: 30)
        toolbarItem.maxSize = CGSize(width: 100, height: 100)
        toolbarItem.label = toolbarItemInfo.title
        toolbarItem.image = toolbarItemInfo.image
        toolbarItem.target = self
        toolbarItem.action = #selector(SettingWindow.toolbarItemSelected(_:))
        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        var identifiers: [String] = []
        toolbarItemInfos.forEach { (toolbarItemInfo) in
            identifiers.append(toolbarItemInfo.identifier)
        }
        return identifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    // MARK: - private
    func toolbarItemSelected(_ sender: NSToolbarItem) {
        itemSelected(selectedItemIdentifier: sender.itemIdentifier)
    }

    private func itemSelected(selectedItemIdentifier: String) {
        if nowShowItemIdentifier == selectedItemIdentifier {
            return
        }
        nowShowItemIdentifier = selectedItemIdentifier
        toolbarItemInfos.forEach { (toolbarItemInfo) in
            if selectedItemIdentifier == toolbarItemInfo.identifier {
                title = toolbarItemInfo.title
                contentViewController = toolbarItemInfo.viewController
                return
            }
        }
    }
}

class ToolbarItemInfo {
    var title: String!
    var image: NSImage!
    var viewController: NSViewController!
    var identifier: String!

    init(title: String, image: NSImage, viewController: NSViewController, identifier: String) {
        self.title = title
        self.image = image
        self.viewController = viewController
        self.identifier = identifier
    }
}
