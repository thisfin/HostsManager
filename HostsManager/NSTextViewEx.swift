//
//  NSTextViewEx.swift
//  RichTextView
//
//  Created by wenyou on 2017/4/13.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

extension NSTextView {
    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == .keyDown {
            switch event.modifierFlags.rawValue & NSEventModifierFlags.deviceIndependentFlagsMask.rawValue {
            case NSEventModifierFlags.command.rawValue:
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) {
                        return true
                    }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) {
                        return true
                    }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) {
                        return true
                    }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) {
                        return true
                    }
                case "a":
                    if NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self) {
                        return true
                    }
                default:
                    ()
                }
            case NSEventModifierFlags.command.rawValue | NSEventModifierFlags.shift.rawValue:
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) {
                        return true
                    }
                }
            default:
                ()
            }
        }
        return super.performKeyEquivalent(with: event)
    }

    // 注释用其他颜色做渲染 以后用子类来扩展, 用 extension 有点挫
    func resetFontColorStyle() {
        if let textStorage = self.textStorage {
            let string = textStorage.string

            textStorage.beginEditing()
            textStorage.removeAttribute(NSForegroundColorAttributeName, range: NSMakeRange(0, string.characters.count))
            textStorage.addAttribute(NSForegroundColorAttributeName, value: Constants.hostFontColor, range: NSMakeRange(0, string.characters.count))
            textStorage.endEditing()

            let regex = try! NSRegularExpression.init(pattern: "#.*$", options: [.anchorsMatchLines])

            regex.enumerateMatches(in: string, options: [], range: NSRange.init(location: 0, length: string.characters.count)) { (textCheckingResult, matchingFlags, b) in
                if let range = textCheckingResult?.range {
                    textStorage.beginEditing()
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: Constants.hostNoteFontColor, range: range)
                    textStorage.endEditing()
                }
            }
        }
    }
}
