//
//  SettingWindow.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/27.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class SettingWindow: NSWindow, NSToolbarDelegate {
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        toolbar = {
            let toolbar = NSToolbar(identifier: "WYToolbarIdentifier") // 默认构造函数有问题!!!
            toolbar.allowsUserCustomization = true
            toolbar.autosavesConfiguration = false
            toolbar.displayMode = .iconAndLabel
            toolbar.sizeMode = .default
            toolbar.delegate = self
            return toolbar
        }()
    }

    // MARK: - NSToolbarDelegate
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        //        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        let toolbarItem = NSToolbarItem()
        toolbarItem.label = "add"
        toolbarItem.paletteLabel = "Add"
        toolbarItem.toolTip = "a dd"
        toolbarItem.minSize = CGSize(width: 25, height: 25)
        toolbarItem.maxSize = CGSize(width: 100, height: 100)
        toolbarItem.target = self
        //        toolbarItem.action = #selelctor()
        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [NSToolbarShowColorsItemIdentifier,
                NSToolbarFlexibleSpaceItemIdentifier,
                NSToolbarCustomizeToolbarItemIdentifier]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [NSToolbarShowColorsItemIdentifier,
                NSToolbarSeparatorItemIdentifier,
                NSToolbarSpaceItemIdentifier,
                NSToolbarFlexibleSpaceItemIdentifier,
                NSToolbarCustomizeToolbarItemIdentifier]
    }
}
