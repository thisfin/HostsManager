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
}
