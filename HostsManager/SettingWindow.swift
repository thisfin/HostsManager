//
//  SettingWindow.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/27.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import WYKit

class SettingWindow: NSWindow, NSToolbarDelegate {
    private let toolbarItemInfos: [ToolbarItemInfo] = [
        ToolbarItemInfo(title: "edit",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontEdit, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(40, 40)), viewController: EditorViewController(), identifier: "a"),
        ToolbarItemInfo(title: "hosts",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontText, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(40, 40)), viewController: SourceViewController(), identifier: "b"),
        ToolbarItemInfo(title: "setting",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontCog, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(40, 40)), viewController: SettingViewController(), identifier: "c")
    ]

    private var nowShowItemIdentifier: String = ""

    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        self.minSize = NSMakeSize(AppDelegate.windowSize.width, AppDelegate.windowSize.height + 22) // 22 是标题栏的高度
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
        var toolbarItemInfo: ToolbarItemInfo?
        toolbarItemInfos.forEach { (info) in
            if info.identifier == itemIdentifier {
                toolbarItemInfo = info
                return
            }
        }
        guard let info = toolbarItemInfo else {
            return nil
        }
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.minSize = NSMakeSize(30, 30)
        toolbarItem.maxSize = NSMakeSize(100, 100)
        toolbarItem.label = info.title
        toolbarItem.image = info.image
        toolbarItem.target = self
        toolbarItem.action = #selector(SettingWindow.toolbarItemSelected(_:))
        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        // return toolbarItemInfos.map {$0.identifier}
        let identifiers = toolbarItemInfos.map { (toolbarItemInfo) -> String in
            return toolbarItemInfo.identifier
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

private struct ToolbarItemInfo {
    var title: String
    var image: NSImage
    var viewController: NSViewController
    var identifier: String
}
