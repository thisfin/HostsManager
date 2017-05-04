//
//  CALayerEx.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/7.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

extension CALayer {
    // 边框选配
    func addBorder(edges: [NSRectEdge], color: NSColor, thickness: CGFloat) {
        edges.forEach { (edge) in
            let border = CALayer()
            switch edge {
            case .minY:
                border.frame = NSMakeRect(0, 0, frame.width, thickness)
                border.autoresizingMask = [.layerMaxYMargin, .layerWidthSizable]
            case .maxY:
                border.frame = NSMakeRect(0, frame.height - thickness, frame.width, thickness)
                border.autoresizingMask = [.layerMinYMargin, .layerWidthSizable]
            case .minX:
                border.frame = NSMakeRect(0, 0, thickness, frame.height)
                border.autoresizingMask = [.layerMaxXMargin, .layerHeightSizable]
            case .maxX:
                border.frame = NSMakeRect(frame.width - thickness, 0, thickness, frame.height)
                border.autoresizingMask = [.layerMinXMargin, .layerHeightSizable]
            }
            border.backgroundColor = color.cgColor;
            addSublayer(border)
        }
    }
}
