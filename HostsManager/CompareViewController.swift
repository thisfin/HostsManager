//
//  CompareViewController.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/4.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit
import SnapKit

class CompareViewController: NSViewController {
    private let leftTextView = NSTextView.init()
    private let rightTextView = NSTextView.init()

    var compareWindowCloseBlock: SimpleBlockNoneParameter?

    override func loadView() {
        self.view = NSView.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect.init(origin: .zero, size: AppDelegate.windowSize)

        let leftScrollView = NSScrollView.init()
        view.addSubview(leftScrollView)
        let rightScrollView = NSScrollView.init()
        view.addSubview(rightScrollView)

        let leftButton = NSButton.init(title: "以 hosts 文件为主", target: self, action: #selector(CompareViewController.leftButtonClicked(_:)))
        view.addSubview(leftButton)
        let rightButton = NSButton.init(title: "以本程序配置为主", target: self, action: #selector(CompareViewController.rightButtonClicked(_:)))
        view.addSubview(rightButton)

        leftButton.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(0 - Constants.marginWidth)
            maker.width.equalTo(180)
            maker.centerX.equalTo(leftScrollView)
        }

        rightButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(leftButton)
            maker.width.equalTo(leftButton)
            maker.centerX.equalTo(rightScrollView)
        }

        leftScrollView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(Constants.marginWidth)
            maker.top.equalToSuperview().offset(Constants.marginWidth)
            maker.bottom.equalTo(leftButton.snp.top).offset(0 - Constants.marginWidth)
            maker.right.equalTo(rightScrollView.snp.left).offset(0 - Constants.marginWidth)
            maker.width.equalTo(rightScrollView)
        }

        rightScrollView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(Constants.marginWidth)
            maker.bottom.equalTo(rightButton.snp.top).offset(0 - Constants.marginWidth)
            maker.right.equalToSuperview().offset(0 - Constants.marginWidth)
        }

        leftScrollView.documentView = leftTextView
        leftScrollView.hasVerticalScroller = true
        leftScrollView.hasHorizontalScroller = true
        leftTextView.frame = NSRect.init(origin: .zero, size: leftScrollView.frame.size)
        leftTextView.autoresizingMask = [.viewHeightSizable, .viewWidthSizable]
        leftTextView.textContainerInset = .zero
        leftTextView.backgroundColor = .textBackgroundColor
        leftTextView.isEditable = false
        leftTextView.menu = nil
        leftTextView.isVerticallyResizable = true
        leftTextView.isHorizontallyResizable = true
        leftTextView.textContainer?.widthTracksTextView = false
        leftTextView.textContainer?.heightTracksTextView = false
        leftTextView.maxSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        leftTextView.textContainer?.containerSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        leftTextView.font = Constants.hostFont

        rightScrollView.documentView = rightTextView
        rightScrollView.hasVerticalScroller = true
        rightScrollView.hasHorizontalScroller = true
        rightTextView.frame = NSRect.init(origin: .zero, size: rightScrollView.frame.size)
        rightTextView.autoresizingMask = [.viewHeightSizable, .viewWidthSizable]
        rightTextView.textContainerInset = .zero
        rightTextView.backgroundColor = .textBackgroundColor
        rightTextView.isEditable = false
        rightTextView.menu = nil
        rightTextView.isVerticallyResizable = true
        rightTextView.isHorizontallyResizable = true
        rightTextView.textContainer?.widthTracksTextView = false
        rightTextView.textContainer?.heightTracksTextView = false
        rightTextView.maxSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        rightTextView.textContainer?.containerSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        rightTextView.font = Constants.hostFont

        leftScrollView.rulersVisible = true
        leftScrollView.hasVerticalRuler = true
        leftScrollView.verticalRulerView = TextVerticalRulerView(textView: leftTextView)
        leftTextView.string = HostsFileManager.sharedInstance.readContentStringFromFile()
        leftTextView.resetFontColorStyle()

        rightScrollView.rulersVisible = true
        rightScrollView.hasVerticalRuler = true
        rightScrollView.verticalRulerView = TextVerticalRulerView(textView: rightTextView)
        rightTextView.string = HostDataManager.sharedInstance.toCompareContent()
        rightTextView.resetFontColorStyle()
    }

    // MARK: - private func
    func leftButtonClicked(_ sender: NSButton) {
        let alert = NSAlert.init()
        alert.messageText = "注意!"
        alert.informativeText = "覆盖后, 之前保存的组信息会全部清空"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "取消")
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: NSApp.mainWindow!) { (modalResponse) in
            switch modalResponse {
            case NSAlertSecondButtonReturn:
                let hostsFileManager = HostsFileManager.sharedInstance
                let groups = hostsFileManager.readContentFromFile()
                if groups.count == 1 && groups[0].name == nil {
                    groups[0].name = "Default"
                }
                let hostDataManager = HostDataManager.sharedInstance
                hostDataManager.groups = groups
                hostDataManager.updateGroupData()
                hostsFileManager.saveMD5()

                if let block = self.compareWindowCloseBlock {
                    block()
                }
            default:
                ()
            }
        }
    }

    func rightButtonClicked(_ sender: NSButton) {
        HostsFileManager.sharedInstance.writeContentToFile(content: HostDataManager.sharedInstance.groups)
        if let block = self.compareWindowCloseBlock {
            block()
        }
    }

    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier.create(type: CompareViewController.self)
        touchBar.defaultItemIdentifiers = [.file, .record]
        return touchBar
    }
}

extension CompareViewController: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem.init(identifier: identifier)
        switch identifier {
        case NSTouchBarItemIdentifier.file:
            let button = NSButton(title: "以 hosts 文件为主", target: self, action: #selector(leftButtonClicked(_:)))
            touchBarItem.view = button
        case NSTouchBarItemIdentifier.record:
            let button = NSButton(title: "以本程序配置为主", target: self, action: #selector(rightButtonClicked(_:)))
            touchBarItem.view = button
        default:
            ()
        }
        return touchBarItem
    }
}

private extension NSTouchBarItemIdentifier {
    static let file = create(type: CompareViewController.self, suffix: "file")
    static let record = create(type: CompareViewController.self, suffix: "record")
}
