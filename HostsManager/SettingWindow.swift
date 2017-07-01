//
//  SettingWindow.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/27.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import WYKit

class SettingWindow: NSWindow {
    enum SettingWindowViewControllerIdentifier: String {
        case edit, hosts, setting
    }

    fileprivate struct ToolbarItemInfo {
        var title: String
        var image: NSImage
        var viewController: NSViewController
        var identifier: String
    }

    fileprivate var segmentedControl: NSSegmentedControl!

    fileprivate let toolbarItemInfos: [ToolbarItemInfo] = [
        ToolbarItemInfo(title: SettingWindowViewControllerIdentifier.edit.rawValue,
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontEdit, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(40, 40)),
                        viewController: EditorViewController(),
                        identifier: SettingWindowViewControllerIdentifier.edit.rawValue),
        ToolbarItemInfo(title: SettingWindowViewControllerIdentifier.hosts.rawValue,
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontText, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(40, 40)),
                        viewController: SourceViewController(),
                        identifier: SettingWindowViewControllerIdentifier.hosts.rawValue),
        ToolbarItemInfo(title: SettingWindowViewControllerIdentifier.setting.rawValue,
                        image: WYIconfont.imageWithIcon(content: Constants.iconfontCog, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(40, 40)),
                        viewController: SettingViewController(),
                        identifier: SettingWindowViewControllerIdentifier.setting.rawValue)]

    private var nowShowItemIdentifier: String = ""

    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        self.delegate = self
        self.isReleasedWhenClosed = false
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

        segmentedControl = NSSegmentedControl.init(labels: toolbarItemInfos.map({ (toolbarItemInfo) -> String in
            return toolbarItemInfo.title
        }), trackingMode: .selectOne, target: self, action: #selector(SettingWindow.segmentSelected(_:)))

        // 设置默认值
        toolbarItemSelected(identifier: .edit)
    }

    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier.create(type: SettingWindow.self)
        touchBar.defaultItemIdentifiers = {
            if contentViewController is EditorViewController {
                return [.segment, .add, .revert, .save]
            }
            return [.segment]
        }()
        return touchBar
    }

    // MARK: - private
    fileprivate func itemSelected(selectedItemIdentifier: String) {
        if nowShowItemIdentifier == selectedItemIdentifier {
            return
        }
        nowShowItemIdentifier = selectedItemIdentifier
        toolbarItemInfos.forEach { (toolbarItemInfo) in
            if selectedItemIdentifier == toolbarItemInfo.identifier {
                title = toolbarItemInfo.title
                if let controller = contentViewController { // 多 controller 切换 window 的 size 保持一致
                    toolbarItemInfo.viewController.view.frame = controller.view.frame
                }
                contentViewController = toolbarItemInfo.viewController
                return
            }
        }
    }

    // 本地初始化 & 状态栏菜单用
    func toolbarItemSelected(identifier: SettingWindowViewControllerIdentifier) {
        toolbar?.selectedItemIdentifier = identifier.rawValue
        itemSelected(selectedItemIdentifier: identifier.rawValue)
        if #available(OSX 10.12.2, *) {
            segmentedControl.selectedSegment = getIndex(identifier: identifier.rawValue)
            touchBar = nil
        }
    }

    // toolbar 点击事件
    func toolbarItemSelected(_ sender: NSToolbarItem) {
        itemSelected(selectedItemIdentifier: sender.itemIdentifier)
        if #available(OSX 10.12.2, *) {
            segmentedControl.selectedSegment = getIndex(identifier: sender.itemIdentifier)
            touchBar = nil // touchbar 更新放在 contentViewController 更新后, 因为 touchbar 需要根据 contentViewController 的类型做判断
        }
    }

    // touchbar 点击事件
    func segmentSelected(_ sender: NSSegmentedControl) {
        let identifier = toolbarItemInfos[sender.selectedSegment].identifier
        toolbar?.selectedItemIdentifier = identifier
        itemSelected(selectedItemIdentifier: identifier)
        if #available(OSX 10.12.2, *) {
            touchBar = nil
        }
    }

    private func getIndex(identifier: String) -> Int {
        for i in 0 ..< toolbarItemInfos.count {
            if toolbarItemInfos[i].identifier == identifier {
                return i
            }
        }
        return 0
    }
}

extension SettingWindow: NSToolbarDelegate {
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
}

extension SettingWindow: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem.init(identifier: identifier)
        switch identifier {
        case NSTouchBarItemIdentifier.segment:
            touchBarItem.view = segmentedControl
        case NSTouchBarItemIdentifier.add:
            touchBarItem.view = NSButton.init(title: "增加 Group", target: (contentViewController as! EditorViewController).toolView, action: #selector(GroupToolView.addButtonClicked(_:)))
        case NSTouchBarItemIdentifier.revert:
            touchBarItem.view = NSButton.init(title: "回退至上次保存", target: (contentViewController as! EditorViewController).toolView.toolMenu, action: #selector(ToolMenu.revertClicked(_:)))
        case NSTouchBarItemIdentifier.save:
            touchBarItem.view = NSButton.init(title: "应用更改", target: (contentViewController as! EditorViewController).toolView, action: #selector(GroupToolView.saveButtonClicked(_:)))
        default:
            ()
        }
        return touchBarItem
    }
}

extension SettingWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: Any) -> Bool {
        self.performMiniaturize(self)
        return false
    }
}

private extension NSTouchBarItemIdentifier {
    static let segment = create(type: SettingWindow.self, suffix: "segment")
    static let add = create(type: SettingWindow.self, suffix: "add")
    static let save = create(type: SettingWindow.self, suffix: "save")
    static let revert = create(type: SettingWindow.self, suffix: "revert")
}
