//
//  WYIconfont.swift
//  SwiftQRCodeScan
//
//  Created by wenyou on 2016/11/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation
import Cocoa
import CoreText

class WYIconfont: NSObject {
    private static var fontName = "FontAwesome"
    private static var fontPath = "fontawesome-webfont_4.6.3"

    // once范例
    static var oneTimeThing: () = {
        let frameworkBundle: Bundle = Bundle(for: WYIconfont.classForCoder())
        let path: String? = frameworkBundle.path(forResource: WYIconfont.fontPath, ofType: "ttf")
        if let dynamicFontData = NSData(contentsOfFile: path!) {
            let dataProvider: CGDataProvider? = CGDataProvider(data: dynamicFontData)
            let font: CGFont? = CGFont(dataProvider!)
            var error: Unmanaged<CFError>? = nil

            if !CTFontManagerRegisterGraphicsFont(font!, &error) {
                let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
                NSLog("Failed to load font: %@", errorDescription as String)
            }
            error?.release()
        }
    }()

    // MARK: - public
    static func setFont(fontPath: String, fontName: String) {
        WYIconfont.fontPath = fontPath
        WYIconfont.fontName = fontName
    }

    static func fontOfSize(_ fontSize: CGFloat) -> NSFont {
        _ = oneTimeThing

        let font: NSFont? = NSFont(name: WYIconfont.fontName, size: fontSize)
        assert(font != nil, WYIconfont.fontName + " couldn't be loaded")
        return font!
    }

    static func imageWithIcon(content: String, backgroundColor: NSColor = NSColor.clear, iconColor: NSColor = NSColor.white, size: CGSize) -> NSImage {
        // 逐步缩小算字号
        var fontSize: Int!
        let constraintSize = CGSize(width: size.width, height: CGFloat(MAXFLOAT))
        for i in stride(from: 500, to: 5, by: -2) {
            let rect = content.boundingRect(with: constraintSize,
                                            options: NSStringDrawingOptions.usesFontLeading,
                                            attributes: [NSFontAttributeName: WYIconfont.fontOfSize(CGFloat(i))],
                                            context: nil)
            fontSize = i
            if rect.size.height <= size.height {
                break
            }
        }

        // 绘制
        let textRext = CGRect(origin: CGPoint.zero, size: size)
        let image = NSImage(size: size)
        image.lockFocus()
//        let context : CGContext = (NSGraphicsContext.current()?.cgContext)!
//        context.beginPath()
        backgroundColor.setFill()
        NSBezierPath(rect: textRext).fill()
        content.draw(in:textRext, withAttributes: [NSFontAttributeName: WYIconfont.fontOfSize(CGFloat(fontSize)),
                                                   NSForegroundColorAttributeName: iconColor,
                                                   NSBackgroundColorAttributeName: backgroundColor,
                                                   NSParagraphStyleAttributeName: {
                                                    let style = NSMutableParagraphStyle()
                                                    style.alignment = NSTextAlignment.center
                                                    return style}()])
        image.unlockFocus()
        return image
    }

    static func imageWithIcon(content: String, backgroundColor: NSColor = NSColor.clear, iconColor: NSColor = NSColor.white, fontSize: CGFloat) -> NSImage {
        let attributes = [NSFontAttributeName: WYIconfont.fontOfSize(fontSize),
                          NSForegroundColorAttributeName: iconColor,
                          NSBackgroundColorAttributeName: backgroundColor,
                          NSParagraphStyleAttributeName: {
                            let style = NSMutableParagraphStyle()
                            style.alignment = NSTextAlignment.center
                            return style}()]

        var size = content.size(withAttributes: attributes)
        size = CGSize(width: size.width * 1.1, height: size.height * 1.05)
        let image = NSImage(size: size)
        image.lockFocus()
        backgroundColor.setFill()
        NSBezierPath(rect: CGRect(origin: CGPoint.zero, size: size)).fill()
        content.draw(at: CGPoint(x: size.width * 0.05, y: size.height * 0.025), withAttributes: attributes)
        image.unlockFocus()
        return image
    }
}
