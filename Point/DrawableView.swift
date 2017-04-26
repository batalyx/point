//
//  DrawableView.swift
//  Point
//
//  Created by Jonne Itkonen on 24.4.2017.
//  Copyright © 2017 Jonne Itkonen. All rights reserved.
//

import Cocoa

protocol Operation {

}

class DrawRect : Operation {
    init( from start: NSPoint, to end: NSPoint) {

    }
    func draw(_ dirtyRect: NSRect) {
        
    }
}

class DrawableView: NSView {
    var start: NSEvent? = nil
    var end: NSEvent? = nil {
        didSet { self.needsDisplay = true }
    }
    var paths = Array<NSBezierPath>()
    var rects = Array<NSRect>()

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        let ov = NSBezierPath(ovalIn: dirtyRect)
        ov.stroke()
        //debugPrint("\(start)-\(end)")
        if start != nil && end != nil {
            var sp = start!.locationInWindow
            var ep = end!.locationInWindow
            let sx = min(sp.x, ep.x)
            let ex = max(sp.x, ep.x)
            let sy = min(sp.y, ep.y)
            let ey = max(sp.y, ep.y)
            sp = NSPoint(x: sx, y: sy)
            ep = NSPoint(x: ex, y: ey)
// We do not need converting, as we're using fullscreen window & view.
//            let r = self.convert(
//                NSRect(origin: sp,
//                       size: CGSize(width: ep.x-sp.x, height: fabs(ep.y-sp.y))),
//                to: nil)
            let r = NSRect(origin: sp,
                           size: CGSize(width: ep.x-sp.x, height: fabs(ep.y-sp.y)))
            rects.append(r.standardized)
//            let pth = NSBezierPath(roundedRect: r, xRadius: 8.0, yRadius: 8.0)
//            //print(pth)
//            paths.append(pth)
            start = nil
            end = nil
        }
//        for path in paths {
//            path.stroke()
//        }
        for r in rects {
            NSFrameRectWithWidth(r, 2.0)
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard start == nil else { return }
        start = event
    }

    override func mouseUp(with event: NSEvent) {
        guard end == nil else { return }
        end = event
        //self.needsDisplay = true
    }

    override func mouseMoved(with event: NSEvent) {
        // ..
    }

    override func keyDown(with event: NSEvent) {
        if let keys = event.characters {
            if keys[keys.startIndex] == "-" {
                if paths.count > 0 {
                    paths.removeLast()
                }
                if rects.count > 0 {
                    rects.removeLast()
                }
                self.needsDisplay = true
            } else {
                super.keyUp(with: event)
            }
        } else {
            super.keyUp(with: event)
        }
    }
}
