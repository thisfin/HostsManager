//
//  ViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor.black
        view.frame = NSRect(origin: NSPoint.zero, size: AppDelegate.windowSize)

//                self.view = {
//                                let view = NSView(frame: NSRect(x: 0, y: 100, width: 300, height: 300))
//                    //            view.wantsLayer = true
//                    //            view.layer?.borderWidth = 2
//                    //            view.layer?.borderColor = NSColor.red.cgColor
//        //            let view = NSView()
//        //            view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
//                    view.wantsLayer = true
//                    view.layer?.backgroundColor = CGColor.black
//                    return view
//                    }()
//
//        NSLog("%@", view)
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    override func loadView() {
        view = NSView()
    }

//    override func loadView() {
//        super.loadView()
//        self.view = {
//                        let view = NSView(frame: NSRect(x: 0, y: 100, width: 300, height: 300))
//            //            view.wantsLayer = true
//            //            view.layer?.borderWidth = 2
//            //            view.layer?.borderColor = NSColor.red.cgColor
////            let view = NSView()
////            view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
//            view.wantsLayer = true
//            view.layer?.backgroundColor = CGColor.black
//            return view
//            }()

//        NSLog("%@", view)
//    }

    override func viewWillAppear() {
        super.viewWillAppear()

        view.addSubview({
            //            let imageView = NSImageView(image: WYIconfont.imageWithIcon(content: "\u{f03a}", backgroundColor: .yellow, iconColor: .white, size: CGSize(width: 50, height: 50)))
            let imageView = NSImageView(image: WYIconfont.imageWithIcon(content: "\u{f03a}", fontSize: 40))
            imageView.frame = NSRect(origin: NSPoint.zero, size: (imageView.image?.size)!)
            return imageView
            }())
    }
}
