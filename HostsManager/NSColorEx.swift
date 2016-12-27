//
//  NSColorEx.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

extension NSColor {
    public static func colorWithHexValue(_ hexValue: UInt, alpha: UInt = 255) -> NSColor {
        let r: Float = Float((hexValue & 0x00FF0000) >> 16) / 255
        let g: Float = Float((hexValue & 0x0000FF00) >> 8) / 255
        let b: Float = Float(hexValue & 0x000000FF) / 255
        let a: Float = Float(alpha) / 255
        return self.init(colorLiteralRed: r, green: g, blue: b, alpha: a)
    }

    // param string "aarrggbb" or "#aarrggbb" or "rrggbb" or "#rrggbb" or "rgb" or "#rgb"
    public static func colorWithString(_ string: String) -> NSColor {
        let len = string.characters.count
        var hexValue = UInt(0)
        var alpha = UInt(255)
        if (len == 8 || (len == 9 && string.characters.first == "#")) {
            hexValue = hexValueOfString(string.lowercased())
            alpha = (hexValue & 0xFF000000) >> 24
            hexValue = hexValue & 0x00FFFFFF
        } else if (len == 6 || (len == 7 && string.characters.first == "#")) {
            hexValue = hexValueOfString(string.lowercased())
            alpha = 255
        } else if (len == 3 || (len == 4 && string.characters.first == "#")) {
            hexValue = hexValueOfString(string.lowercased())
            alpha = 255
        }
        return colorWithHexValue(hexValue, alpha: alpha)
    }

    private static func hexValueOfString(_ string: String) -> UInt {
        var string: String = string

        if string.hasPrefix("#") {
            string = string.substring(from: string.index(string.startIndex, offsetBy: 1))
        } else if string.hasPrefix("0x") {
            string = string.substring(from: string.index(string.startIndex, offsetBy: 2))
        }

        if string.characters.count == 3 {
            var s = ""
            string.characters.forEach({ (c) in
                s.append(c)
                s.append(c)
            })
            string = s
        }
        // string = string.characters.reduce("", {$0 + String($1) + String($1)})

        var i32: UInt32 = 0
        let scanner = Scanner(string: string)
        scanner.scanHexInt32(&i32)

        return UInt(i32)
    }
}
