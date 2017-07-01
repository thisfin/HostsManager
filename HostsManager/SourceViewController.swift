//
//  SourceViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

class SourceViewController: NSViewController {
    private let textView = NSTextView()

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true // 不设置的话行号的字体渲染不对, 待排查
        view.frame = NSRect(origin: NSPoint.zero, size: AppDelegate.windowSize)

        let scrollView = NSScrollView.init()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(Constants.marginWidth)
            maker.top.equalToSuperview().offset(Constants.marginWidth)
            maker.bottom.equalToSuperview().offset(0 - Constants.marginWidth)
            maker.right.equalToSuperview().offset(0 - Constants.marginWidth)
        }

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true

        textView.frame = NSRect.init(origin: .zero, size: textView.frame.size)
        textView.autoresizingMask = [.viewHeightSizable, .viewWidthSizable]
        textView.textContainerInset = .zero
        textView.backgroundColor = .textBackgroundColor
        textView.isEditable = false
        textView.menu = nil
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.heightTracksTextView = false
        textView.maxSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        textView.textContainer?.containerSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        textView.font = Constants.hostFont

        scrollView.rulersVisible = true
        scrollView.hasVerticalRuler = true
        scrollView.verticalRulerView = TextVerticalRulerView(textView: textView)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        textView.string = HostsFileManager.sharedInstance.readContentStringFromFile()
        textView.resetFontColorStyle()
    }
}
