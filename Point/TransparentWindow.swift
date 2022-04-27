//
//  TransparentWindow.swift
//  Point
//
//  Created by Jonne Itkonen on 24.4.2017.
//  Copyright © 2017 Jonne Itkonen. All rights reserved.
//

import Cocoa

class TransparentWindow: NSWindow {

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        isOpaque = false
        // hasShadow = false
        backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0, alpha: 0.1);//NSColor.clear
        backgroundColor = NSColor(red: 0.4, green: 0.4, blue: 0.3, alpha: 0.1);//NSColor.clear
        self.title = "Point"
//        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        debugPrint("TransparentWindow parent = \(String(describing: self.parent))")
    }
}

extension NSWindowController {
    func maximize() { self.window?.zoom(self) }
}
