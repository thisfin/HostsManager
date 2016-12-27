//
//  SettingWindow.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/27.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class SettingWindow: NSWindow, NSToolbarDelegate {
    lazy var settingViewController: ViewController = {
        return ViewController()
    }()

    let toolbarItemInfos: [ToolbarItemInfo] = [
        ToolbarItemInfo(title: "编辑",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontScan, backgroundColor: .clear, iconColor: .black, fontSize: 40),
                        viewController: ViewController(),
                        identifier: "a"),
        ToolbarItemInfo(title: "查看源文件",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontImage, backgroundColor: .clear, iconColor: .black, fontSize: 40),
                        viewController: ViewController(),
                        identifier: "b"),
        ToolbarItemInfo(title: "设置",
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontlight, backgroundColor: .clear, iconColor: .black, fontSize: 40),
                        viewController: ViewController(),
                        identifier: "c")
    ]

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

        contentViewController = settingViewController
    }

    // MARK: - NSToolbarDelegate
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
//        let toolbarItem = NSToolbarItem()
        var toolbarItemInfo: ToolbarItemInfo!
        for info in toolbarItemInfos {
            if info.identifier == itemIdentifier {
                toolbarItemInfo = info
            }
        }
        toolbarItem.label = toolbarItemInfo.title
        toolbarItem.image = toolbarItemInfo.image
        toolbarItem.paletteLabel = "Add"
        toolbarItem.toolTip = "a dd"
//        toolbarItem.minSize = CGSize(width: 25, height: 25)
//        toolbarItem.maxSize = CGSize(width: 100, height: 100)
        toolbarItem.target = self
        //        toolbarItem.action = #selelctor()
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
