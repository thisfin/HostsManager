//
//  AppDelegate.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import WYKit

@NSApplicationMain
class AppDelegate: NSObject {
    static let windowSize = NSMakeSize(800, 500)

    fileprivate var rootStatusItem: NSStatusItem!
    fileprivate lazy var settingWindow = SettingWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)
    fileprivate lazy var compareWindow = CompareWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)

    fileprivate func setMainMenu() {
        NSApp.mainMenu = {
            let menu = NSMenu()
            menu.addItem({
                let iconfontPreviewItem = NSMenuItem()
                iconfontPreviewItem.submenu = {
                    let submenu = NSMenu()
                    submenu.addItem(withTitle: "About \(ProcessInfo.processInfo.processName)", action: #selector(NSApp.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
                    submenu.addItem(NSMenuItem.separator())
                    submenu.addItem(withTitle: "Hide \(ProcessInfo.processInfo.processName)", action: #selector(NSApp.hide(_:)), keyEquivalent: "h")
                    submenu.addItem({
                        let menuItem = NSMenuItem(title: "Hide Others", action: #selector(NSApp.hideOtherApplications(_:)), keyEquivalent: "h")
                        menuItem.keyEquivalentModifierMask = [.command, .option]
                        return menuItem
                        }())
                    submenu.addItem(withTitle: "Show All", action: #selector(NSApp.unhideWithoutActivation), keyEquivalent: "")
                    submenu.addItem(NSMenuItem.separator())
                    submenu.addItem(withTitle: "Quit \(ProcessInfo.processInfo.processName)", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q")
                    return submenu
                }()
                return iconfontPreviewItem
                }())
            menu.addItem({
                let menuItem = NSMenuItem()
                menuItem.submenu = {
                    let submenu = NSMenu(title: "File")
                    submenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
                    return submenu
                }()
                return menuItem
                }())
            menu.addItem({
                let menuItem = NSMenuItem()
                menuItem.submenu = NSMenu(title: "View")
                return menuItem
                }())
            menu.addItem({
                let menuItem = NSMenuItem()
                menuItem.submenu = {
                    let submenu = NSMenu(title: "Window")
                    submenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
                    submenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
                    submenu.addItem(NSMenuItem.separator())
                    submenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApp.arrangeInFront(_:)), keyEquivalent: "")
                    return submenu
                }()
                return menuItem
                }())
            return menu
        }()
    }

    fileprivate func setStatusItem() {
        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = WYIconfont.imageWithIcon(content: Constants.iconfontRandom, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(20, 20))
        rootStatusItem.menu = StatusMenu(statusItem: rootStatusItem)
    }

    fileprivate func bookmarkCheck() {
        let filePermissions = FilePermissions.sharedInstance
        if filePermissions.isBookmarkExist(bookmarkKey: Constants.hostsFileBookmarkKey) {
            return
        }
        let panel = NSOpenPanel().then { (this) in
            this.message = "因为 AppStore 上架限制, 沙盒环境没有直接访问系统文件的权限, 请在下面选择 hosts 文件来获得访问权限."
            this.directoryURL = Constants.hostsFileURL
            this.canChooseDirectories = false
            this.allowedFileTypes = [""]
        }
        switch panel.runModal() {
        case NSFileHandlingPanelOKButton:
            if let url = panel.url {
                if url.path == Constants.hostsFileURL.path {
                    filePermissions.addBookmark(url: url, bookmarkKey: Constants.hostsFileBookmarkKey)
                }
            }
            bookmarkCheck()
        default:
            NSApp.terminate(self)
        }
    }
}

extension AppDelegate: NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        if !PreferenceManager.sharedInstance.propertyInfo.dockIconShow { // 详见 SettingViewController
            _ = NSApp.setActivationPolicy(.accessory)
            // 这个方法是异步的, 会将创建的 window 关掉, 所以后面的 window 做了 hide = false 的处理
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 布局约束冲突 visualizeConstraints
        // UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")

        FilePermissions.sharedInstance.hostsFileReadPermissionsCheck()
        bookmarkCheck()

        setMainMenu()

        // 文件版本校验
        let hostsFileManager = HostsFileManager.sharedInstance
        switch hostsFileManager.checkHostsFile() {
        case .NeverInit:
            // 读取 hosts 文件写入本地缓存
            let groups = hostsFileManager.readContentFromFile()
            if groups.count == 1 && groups[0].name == nil {
                groups[0].name = "Default"
            }

            let hostDataManager = HostDataManager.sharedInstance
            hostDataManager.groups = groups
            hostDataManager.updateGroupData()
            hostsFileManager.saveMD5()

            settingWindow.canHide = false // 防止窗口不被 setActivationPolicy 关掉
            settingWindow.center()
            settingWindow.makeKeyAndOrderFront(self)

            WYHelp.alertInformational(title: "第一次使用初始化", message: "\(Constants.hostsFileURL.path) 文件中的内容已经导入配置, group 为 Default.", window: settingWindow, completionHandler: { (response) in
                self.settingWindow.canHide = true
                self.setStatusItem()
            })
        case .FileChange:
            // 弹出对比页面进行处理
            // hosts 为主 走上面的流程
            // 缓存为主 则写入 hosts, 记录 md5
            compareWindow.closeBlock = {
                HostDataManager.sharedInstance.loadFile()
                self.settingWindow.center()
                self.settingWindow.makeKeyAndOrderFront(self)
                self.compareWindow.orderOut(self)
                self.setStatusItem()
            }
            compareWindow.canHide = false // 防止窗口不被 setActivationPolicy 关掉
            compareWindow.center()
            compareWindow.makeKeyAndOrderFront(self)

            WYHelp.alertWarning(title: "文件检查", message: "\(Constants.hostsFileURL.path) 文件版本与程序中保存的不一致(可能是因为通过别的编辑器修改过), 请处理", window: compareWindow, completionHandler: { (response) in
                self.compareWindow.canHide = true
            })
        case .FileUnchange:
            settingWindow.center()
            settingWindow.makeKeyAndOrderFront(self)
            setStatusItem() // 状态栏 放在后面, 因为前面有文件版本校验的逻辑
        }
    }
}
