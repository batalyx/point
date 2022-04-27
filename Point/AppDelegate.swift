//
//  AppDelegate.swift
//  Point
//
//  Created by Jonne Itkonen on 24.4.2017.
//  Copyright © 2017 Jonne Itkonen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let screen = NSScreen.main {
            if let nsa:NSApplication = aNotification.object as? NSApplication {
                if let window = nsa.mainWindow {
                    window.setFrame(screen.visibleFrame, display: true, animate: true)
                } else {
                    debugPrint("no main window");
                }
            } else {
                debugPrint("no nsa :)");
            }
        } else {
            debugPrint("no screen :(");
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

