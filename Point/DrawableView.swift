//
//  DrawableView.swift
//  Point
//
//  Created by Jonne Itkonen on 24.4.2017.
//  Copyright © 2017 Jonne Itkonen. All rights reserved.
//

import Cocoa

protocol Marking {
    func draw(_ dirtyRect: NSRect);
}

class DrawRect : Marking {
    var rect: NSRect
    init( from start: NSPoint, to end: NSPoint) {
        rect = NSRect(origin: start,
                      size: NSSize(width: end.x-start.x,
                                   height: fabs(end.y-start.y)))
        rect = rect.standardized
    }

    func draw(_ dirtyRect: NSRect) {
        NSFrameRectWithWidth(rect, 2.0)
    }
}

class DrawableView: NSView {
    var start: NSEvent? = nil
    var end: NSEvent? = nil {
        didSet { self.needsDisplay = true }
    }

    var markings = Array<Marking>()

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let ov = NSBezierPath(ovalIn: dirtyRect)
        ov.stroke()

        if start != nil && end != nil {
            var sp = start!.locationInWindow
            var ep = end!.locationInWindow
            let sx = min(sp.x, ep.x)
            let ex = max(sp.x, ep.x)
            let sy = min(sp.y, ep.y)
            let ey = max(sp.y, ep.y)
            sp = NSPoint(x: sx, y: sy)
            ep = NSPoint(x: ex, y: ey)

            markings.append(DrawRect(from: sp, to: ep))

            start = nil
            end = nil
        }

        for mark in markings {
            mark.draw(dirtyRect)
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard start == nil else { return }
        start = event
    }

    override func mouseUp(with event: NSEvent) {
        guard end == nil else { return }
        end = event
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
                if markings.count > 0 {
                    markings.removeLast()
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
