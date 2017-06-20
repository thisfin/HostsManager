//
//  PopoverViewController.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/20.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class PopoverViewController: NSViewController {
    private let space: CGFloat = 20
    private let textField = NSTextField()
    weak var popover: NSPopover?

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(textField)
        textField.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(space)
            maker.left.equalToSuperview().offset(space)
            maker.bottom.equalToSuperview().offset(0 - space)
            maker.bottom.equalToSuperview().offset(0 - space)
        }
        textField.backgroundColor = .clear
        textField.isEditable = false
        textField.menu = nil
        textField.isBordered = false
        textField.font = Constants.hostFont
    }

    func setText(string: String) {
        textField.stringValue = string
        let size = textField.fittingSize
        if let parent = popover {
            parent.contentSize = NSMakeSize(size.width + space * 2, size.height + space * 2)
        }
    }
}
