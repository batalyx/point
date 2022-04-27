//
//  ViewController.swift
//  Point
//
//  Created by Jonne Itkonen on 24.4.2017.
//  Copyright © 2017 Jonne Itkonen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        if let screen = view.window?.screen ?? NSScreen.main {
//            view.window?.setFrame(screen.visibleFrame, display: true)
//        }
        // Do any additional setup after loading the view.
        //view.window?.zoom(self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            //view.window?.zoom(self)
            if let screen = view.window?.screen ?? NSScreen.main {
                view.window?.setFrame(screen.visibleFrame, display: true)
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseDown(with: event)
    }
}

