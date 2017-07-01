//
//  GroupEditView.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class GroupEditView: NSView {
    fileprivate var rulerView: TextVerticalRulerView!
    fileprivate var textView: NSTextView!
    fileprivate var index: Int?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let scrollView = NSScrollView(frame: CGRect(origin: .zero, size: frameRect.size))
        scrollView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        self.addSubview(scrollView)

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.rulersVisible = true
        scrollView.hasVerticalRuler = true

        textView = NSTextView(frame: CGRect(origin: .zero, size: frameRect.size))
        textView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        textView.delegate = self
        textView.allowsUndo = true
        textView.font = Constants.hostFont
        textView.textColor = Constants.hostFontColor
        textView.backgroundColor = .white
        textView.isEditable = true
        textView.isSelectable = true
        textView.usesFontPanel = false // 禁掉右键菜单中的字体选择
        textView.menu = nil // 禁掉右键菜单
        textView.layoutManager?.typesetter = WYTypesetter()
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.minSize = NSMakeSize(0, scrollView.contentSize.height)
        textView.maxSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        textView.textContainer?.containerSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.heightTracksTextView = false
        textView.textContainerInset = .zero
        textView.postsFrameChangedNotifications = true
        scrollView.documentView = textView
        rulerView = TextVerticalRulerView(textView: textView)
        scrollView.verticalRulerView = rulerView

        NotificationCenter.default.addObserver(self, selector: #selector(GroupEditView.selectorFrameDidChange(_:)), name:.NSViewFrameDidChange, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupEditView.selectorTextDidChange(_:)), name:.NSTextDidChange, object: textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func selectorFrameDidChange(_ sender: NSTextView) {
        rulerView.needsDisplay = true // 行号渲染
    }

    func selectorTextDidChange(_ sender: NSTextView) {
        rulerView.needsDisplay = true // 行号渲染
    }

    func setText(text: String?, index: Int? = nil) {
        self.index = index
        if let t = text {
            isHidden = false
            textView.string = t
            textDidChange(Notification.init(name: .NSTextDidChange)) // 显式调用
        } else  {
            isHidden = true
        }
    }
}

extension GroupEditView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) { // 注释用其他颜色做渲染
        textView.resetFontColorStyle()
        rulerView.needsDisplay = true
        if let row = index, let value = textView.string {
            let group = HostDataManager.sharedInstance.groups[row]
            group.content = value
        }
    }
}
