//
//  SettingViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import ServiceManagement
import SnapKit

class SettingViewController: NSViewController {
    private let startupButton = NSButton.init(checkboxWithTitle: "开机时自启动", target: self, action: #selector(SettingViewController.startupButtonClicked(_:)))
    private let dockIconButton = NSButton.init(checkboxWithTitle: "在 Dock 中显示程序图标", target: self, action: #selector(SettingViewController.dockIconButtonClicked(_:)))

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = NSRect(origin: NSPoint.zero, size: AppDelegate.windowSize)

        view.addSubview(startupButton)
        startupButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.left.equalToSuperview().offset(300)
        }
        view.addSubview(dockIconButton)
        dockIconButton.snp.makeConstraints { (make) in
            make.top.equalTo(startupButton.snp.bottom).offset(20)
            make.left.equalTo(startupButton)
        }

        let textField = NSTextField.init(string: "配置选项:")
        textField.isEditable = false
        textField.isBordered = false
        textField.alignment = .right
        textField.backgroundColor = .clear
        view.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(startupButton.snp.left).offset(-50)
            make.centerY.equalTo(startupButton)
        }
    }

    // 如果要更改默认值, 对应在 PreferenceManager.readPorperty 字段为 nil 的判断时候做
    override func viewWillAppear() {
        super.viewWillAppear()

        let propertyInfo = PreferenceManager.sharedInstance.propertyInfo
        startupButton.state = propertyInfo.startupLogin ? NSOnState : NSOffState
        dockIconButton.state = propertyInfo.dockIconShow ? NSOnState : NSOffState
    }

    func startupButtonClicked(_ sender: NSButton) {
        switch sender.state {
        case NSOnState:
            PreferenceManager.sharedInstance.propertyInfo.startupLogin = true
        case NSOffState:
            PreferenceManager.sharedInstance.propertyInfo.startupLogin = false
        default:
            ()
        }
    }

    func dockIconButtonClicked(_ sender: NSButton) {
        // 另外重新启动的时候需要读取配置重新设置一下, 下面两种方法都可以实现功能
        // 启动的时候如果通过代码禁掉 icon, dock 会闪动, 所以通过 info.plist 里设置 LSUIElement 为 false 默认关闭 dock 里的 icon, 在启动时人工开始 icon (applicationDidFinishLaunching)
        // LSUIElement 为 true, 通过代码手动开启时, mainmenu 会拿不到焦点, 要切换一次才可以
        // 设置默认开启, 通过代码来控制是否关闭的方案: 界面会闪烁; 设置默认关闭, 通过代码来控制是否关闭的方案: mainmenu 第一次会拿不到焦点. 互有优劣
        switch sender.state {
        case NSOnState:
            _ = NSApp.setActivationPolicy(.regular)
            PreferenceManager.sharedInstance.propertyInfo.dockIconShow = true
        case NSOffState:
            NSApp.mainWindow?.canHide = false // 防止下面方法时窗口会关闭
            _ = NSApp.setActivationPolicy(.accessory)
            PreferenceManager.sharedInstance.propertyInfo.dockIconShow = false
        default:
            ()
        }

//        var transformState: ProcessApplicationTransformState?
//        switch sender.state {
//        case NSOnState:
//            transformState = ProcessApplicationTransformState.init(kProcessTransformToForegroundApplication)
//            PreferenceManager.sharedInstance.propertyInfo.dockIconShow = true
//        case NSOffState:
//            NSApp.mainWindow?.canHide = false
//            transformState = ProcessApplicationTransformState.init(kProcessTransformToUIElementApplication)
//            PreferenceManager.sharedInstance.propertyInfo.dockIconShow = false
//        default:
//            ()
//        }
//        if let state = transformState {
//            var psn = ProcessSerialNumber.init(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
//            _ = TransformProcessType(&psn, state)
//        }
    }

    private func startupAppWhenLogin(startup: Bool) {
        let launcherAppIdentifier = "win.sourcecode.HostsManagerHelper"

        _ = SMLoginItemSetEnabled(launcherAppIdentifier as CFString, startup)

        var startedAtLogin = false
        NSWorkspace.shared().runningApplications.forEach { (runningApplication) in
            if let bundleIdentifier = runningApplication.bundleIdentifier, bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
                return
            }
        }
        if startedAtLogin {
            DistributedNotificationCenter.default().post(name: NSNotification.Name.init("KillHelper"), object: Bundle.main.bundleIdentifier)
        }
    }
}
