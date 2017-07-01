//
//  Constants.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

typealias SimpleBlockNoneParameter = () -> Void
typealias SimpleBlock = (_ data: AnyObject) -> Void

class Constants {
    static let colorBianchi = NSColor.colorWithHexValue(0x8bddd1)

    static let colorTableBackground = NSColor.colorWithHexValue(0xf6f6f6)
    static let colorTableBackgroundLight = NSColor.white
    static let colorTableBorder = NSColor.colorWithHexValue(0xc8c8c8)
    static let colorSelected = NSColor.colorWithHexValue(0x00cc00)
    static let colorFont = NSColor.colorWithHexValue(0x333333)

    static let iconfontScan = "\u{f029}"
    static let iconfontHistory = "\u{f03a}"
    static let iconfontlight = "\u{f0e7}"
    static let iconfontImage = "\u{f03e}"
    static let iconfontDelete = "\u{f014}"

    static let iconfontCog = "\u{f013}"
    static let iconfontEdit = "\u{f044}"
    static let iconfontText = "\u{f0f6}"
    static let iconfontRandom = "\u{f074}"

    static let marginWidth: CGFloat = 20

    static let hostsFileURL = URL.init(fileURLWithPath: NSOpenStepRootDirectory() + "etc/hosts")
    static let hostsFileGroupPrefix = "# ``` "

    static let hostInfoFontSize: CGFloat = 14
    static let hostFont = NSFont(name: "PT Mono", size: Constants.hostInfoFontSize)!
    static let hostFontColor = Constants.colorFont
    static let hostNoteFontColor = NSColor.brown
}
