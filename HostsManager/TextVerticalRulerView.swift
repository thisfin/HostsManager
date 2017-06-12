//
//  TextVertiRulerView.swift
//  RichTextView
//
//  Created by wenyou on 2017/3/21.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class TextVerticalRulerView: NSRulerView {
    private let padding: CGFloat = 5 // 行号左右边距

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init (textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)

        needsDisplay = true
        clientView = textView
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        if let textView = clientView as? NSTextView, let layoutManager = textView.layoutManager {
            // textView 内容的高度
            // let contentHeight = layoutManager.usedRect(for: textView.textContainer!).size.height usedRect在光标位置不在尾行的时候不是全部的高度
            let contentHeight = layoutManager.boundingRect(forGlyphRange: NSMakeRange(0, (textView.string?.characters.count)!), in: textView.textContainer!).size.height
            // 行数 = 高度 / 行高
            let lineCount = Int(round(contentHeight / (Constants.hostFont.ascender + abs(Constants.hostFont.descender) + Constants.hostFont.leading)))
            // 计算行号左侧位数差
            let bitDifference = { (lineNumber: Int) -> Int in
                return "\(lineCount)".characters.count - "\(lineNumber)".characters.count
            }
            // 绘制行号
            let drawLineNumber = { (lineNumber: Int, y: CGFloat) -> Void in
                let attString = NSAttributedString(string: "\(lineNumber)",
                                                   attributes: [NSFontAttributeName: Constants.hostFont, NSForegroundColorAttributeName: Constants.hostFontColor])
                let x = self.padding + NSString(string: "8").size(withAttributes: [NSFontAttributeName: Constants.hostFont]).width * CGFloat(bitDifference(lineNumber))
                let relativePoint = self.convert(NSPoint.zero, to: textView)
                // 底部间距 http://ksnowlv.blog.163.com/blog/static/21846705620142325349309/
                let descender = (Constants.hostInfoFontSize - Constants.hostFont.ascender - Constants.hostFont.descender) / 2
                attString.draw(at: NSPoint(x: x, y: 0 - relativePoint.y + y - descender))
            }

            // 可显示区域的文字范围
            let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
            // 可显示区域的第一个文字的 index
            let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
            // 换行符的正则表达式
            let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
            // 可显示区域第一行的行号
            var lineNumber = newLineRegex.numberOfMatches(in: textView.string!, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1
            // 可显示区域的行的首字符的 index
            var glyphIndexForStringLine = visibleGlyphRange.location

            // 遍历可显示区域
            while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
                // 当前行的 range
                let characterRangeForStringLine: NSRange = (textView.string! as NSString).lineRange(for: NSMakeRange(layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), 0))
                // 获取当前行显示范围
                var effectiveRange = NSMakeRange(0, 0)
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForStringLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                drawLineNumber(lineNumber, lineRect.minY)
                // 更新 index
                glyphIndexForStringLine = NSMaxRange(characterRangeForStringLine)
                lineNumber += 1
            }

            // 在文本结尾绘制额外行的行号(貌似最后一行为\n时调用)
            if layoutManager.extraLineFragmentTextContainer != nil {
                drawLineNumber(lineNumber, layoutManager.extraLineFragmentRect.minY)
            }

            // 调整行号区域的宽度
            ruleThickness = CGFloat(String(lineCount).characters.count) * NSString.init(string: "8").size(withAttributes: [NSFontAttributeName: Constants.hostFont]).width + padding * 2
        }
    }
}
