//
//  GroupEditView.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class GroupEditView: NSView, NSTextViewDelegate {
    var rulerView: TextVerticalRulerView!
    var textView: NSTextView!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.backgroundColor = NSColor.orange.cgColor
//        view.frame = NSRect(origin: .zero, size: AppDelegate.windowSize)

//        let scrollView = NSScrollView(frame: CGRect(origin: .zero, size: AppDelegate.windowSize))
        let scrollView = NSScrollView(frame: CGRect(origin: .zero, size: frameRect.size))
        scrollView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        self.addSubview(scrollView)

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true

        scrollView.rulersVisible = true
        scrollView.hasVerticalRuler = true

//        textView = NSTextView(frame: CGRect(origin: .zero, size: scrollView.frame.size))
        textView = NSTextView(frame: CGRect(origin: .zero, size: frameRect.size))
        textView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        scrollView.documentView = textView

        textView.delegate = self
        textView.font = Constants.hostFont
        textView.textColor = Constants.hostFontColor
        // textView.isRulerVisible = true
        textView.backgroundColor = .blue//.white
        // textView.usesRuler = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.usesFontPanel = false // 禁掉右键菜单中的字体选择
        textView.menu = nil // 禁掉右键菜单
        textView.layoutManager?.typesetter = WYTypesetter()
        //        textView.string = "1234567890hahahahahhahahahahhahahahahhahahahahhahahahahhahahahahhahahahah\n1\n2\n3\n4\n5\n6\n7\n8\n8\n8\n8"
        //        textView.string = "电风扇\n"
        textView.string = "d中#sdf"
        self.textDidChange(Notification.init(name: .NSTextDidChange)) // 显式调用

        // let attributedString = NSMutableAttributedString.init(string: "hello")
        // attributedString.addAttributes([NSForegroundColorAttributeName: NSColor.textColor], range: NSRange.init(location: 0, length: attributedString.length))
        // textView.insertText(attributedString, replacementRange: NSRange.init(location: 0, length: (textView.string?.characters.count)!))

        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.minSize = NSMakeSize(0, scrollView.contentSize.height)
        textView.maxSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        textView.textContainer?.containerSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        // textView.textContainer?.containerSize = NSMakeSize(scrollView.contentSize.width, CGFloat(Float.greatestFiniteMagnitude))
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.heightTracksTextView = false
        textView.textContainerInset = .zero
        //        textView.defaultParagraphStyle = {
        //            let style = NSMutableParagraphStyle()
        //            style.lineHeightMultiple = 45
        //            style.maximumLineHeight = 45
        //            style.minimumLineHeight = 45
        //            style.lineSpacing = 8
        //            return style
        //        }()

        textView.postsFrameChangedNotifications = true
        rulerView = TextVerticalRulerView(textView: textView)
        // rulerView = TextVerticalRulerView(scrollView: scrollView, orientation: .verticalRuler)
        scrollView.verticalRulerView = rulerView

        NotificationCenter.default.addObserver(self, selector: #selector(GroupEditView.selectorFrameDidChange(_:)), name:.NSViewFrameDidChange, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupEditView.selectorTextDidChange(_:)), name:.NSTextDidChange, object: textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectorFrameDidChange(_ sender: NSTextView) {
        rulerView.needsDisplay = true // 行号渲染
    }

    func selectorTextDidChange(_ sender: NSTextView) {
        rulerView.needsDisplay = true // 行号渲染
    }

    // MARK: - NSTextViewDelegate
    func textDidChange(_ notification: Notification) { // 注释用其他颜色做渲染
        let string = textView.textStorage?.string

        textView.textStorage?.beginEditing()
        textView.textStorage?.removeAttribute(NSForegroundColorAttributeName, range: NSMakeRange(0, (string?.characters.count)!))
        textView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: Constants.hostFontColor, range: NSMakeRange(0, (string?.characters.count)!))
        textView.textStorage?.endEditing()

        let regex = try! NSRegularExpression.init(pattern: "#.*$", options: [.anchorsMatchLines])

        regex.enumerateMatches(in: string!, options: [], range: NSRange.init(location: 0, length: (string?.characters.count)!)) {
            (textCheckingResult, matchingFlags, b) in
            let range = (textCheckingResult?.range)!
            textView.textStorage?.beginEditing()
            textView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: Constants.hostNoteFontColor, range: range)
            textView.textStorage?.endEditing()
            // NSLog("\((string! as NSString).substring(with: range))")
        }
    }
}
