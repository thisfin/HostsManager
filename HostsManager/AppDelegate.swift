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
class AppDelegate: NSObject, NSApplicationDelegate {
    static let windowSize = NSMakeSize(800, 500)

    private var rootStatusItem: NSStatusItem!
    private lazy var settingWindow = SettingWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)
    private lazy var compareWindow = CompareWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)

    func applicationWillBecomeActive(_ notification: Notification) {
        ()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 布局约束冲突 visualizeConstraints
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")

        if PreferenceManager.sharedInstance.propertyInfo.dockIconShow { // 详见 SettingViewController
            _ = NSApp.setActivationPolicy(.regular)
        }

        // 文件权限操作
        FilePermissions.sharedInstance.hostsFilePermissionsCheck()

        // 菜单
        NSApp.menu = {
            let menu = NSMenu()
            menu.addItem({
                let iconfontPreviewItem = NSMenuItem()
                iconfontPreviewItem.submenu = {
                    let submenu = NSMenu()
                    submenu.addItem(NSMenuItem(title: "About \(ProcessInfo.processInfo.processName)", action: #selector(AppDelegate.about(_:)), keyEquivalent: ""))
                    submenu.addItem(NSMenuItem.separator())
                    submenu.addItem(NSMenuItem(title: "Quit \(ProcessInfo.processInfo.processName)", action: #selector(AppDelegate.quit(_:)), keyEquivalent: ""))
                    return submenu
                }()
                return iconfontPreviewItem
                }())
            return menu
        }()

        // 状态栏
        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = WYIconfont.imageWithIcon(content: Constants.iconfontRandom, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(20, 20))
        rootStatusItem.menu = StatusMenu(statusItem: rootStatusItem)

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

            settingWindow.center()
            settingWindow.makeKeyAndOrderFront(self)

            WYHelp.alertInformational(title: "第一次使用初始化", message: "\(Constants.hostsFileURL.path) 文件中的内容已经导入配置, group 为 Default.", window: settingWindow)
        case .FileChange:
            // 弹出对比页面进行处理
            // hosts 为主 走上面的流程
            // 缓存为主 则写入 hosts, 记录 md5
            compareWindow.closeBlock = {
                HostDataManager.sharedInstance.loadFile()
                self.settingWindow.center()
                self.settingWindow.makeKeyAndOrderFront(self)
                self.compareWindow.orderOut(self)
            }
            compareWindow.center()
            compareWindow.makeKeyAndOrderFront(self)

            WYHelp.alertWarning(title: "文件检查", message: "\(Constants.hostsFileURL.path) 文件版本与程序中保存的不一致(可能是因为通过别的编辑器修改过), 请处理", window: compareWindow)
        case .FileUnchange:
            settingWindow.center()
            settingWindow.makeKeyAndOrderFront(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func about(_ sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(self)
    }

    func quit(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }
}
