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

protocol MarkingFactory {
    func startEvent(_ e: NSEvent)
    func moveEvent(_ e: NSEvent)
    func endEvent(_ e: NSEvent)
    func drawTemp(_ dirtyRect: NSRect)
    func makeMarking() -> Marking?
}


class DrawRect : Marking {
    var rect: NSRect?
    var start: NSPoint?
    var end: NSPoint?

    init(from start: NSPoint, to end: NSPoint) {
        let rect = NSRect(origin: start,
                      size: NSSize(width: end.x-start.x,
                                   height: fabs(end.y-start.y)))
        self.rect = rect //.standardized
    }

    init(withRect r: NSRect) {
        self.rect = r
    }

    func draw(_ dirtyRect: NSRect) {
        if let rect = self.rect {
            NSFrameRectWithWidth(rect, 2.0)
        }
    }

    class Factory : MarkingFactory {
        var start: NSPoint?
        var end: NSPoint?
        var temporaryPath: NSBezierPath?

//        func withStart(_ s: NSPoint) {
//            start = s
//            end = nil
//            NSLog("withstart")
//        }
//
//        func withEnd(_ e: NSPoint) {
//            end = e
//            let sx = min(start!.x, end!.x)
//            let ex = max(start!.x, end!.x)
//            let sy = min(start!.y, end!.y)
//            let ey = max(start!.y, end!.y)
//            start = NSPoint(x: sx, y: sy)
//            end   = NSPoint(x: ex, y: ey)
//            NSLog("withEnd")
//        }

        func startEvent(_ e:NSEvent) {
            start = e.locationInWindow
            end = nil
            temporaryPath = NSBezierPath()
            temporaryPath?.lineWidth = 0.1
            temporaryPath?.move(to: start!)
        }

        func moveEvent(_ e:NSEvent) {
            //end = e.locationInWindow
//            let sx = min(start!.x, end!.x)
//            let ex = max(start!.x, end!.x)
//            let sy = min(start!.y, end!.y)
//            let ey = max(start!.y, end!.y)
//            start = NSPoint(x: sx, y: sy)
//            end   = NSPoint(x: ex, y: ey)

            if let pth = self.temporaryPath {
                pth.line(to: e.locationInWindow)
            }
        }

        func endEvent(_ e:NSEvent) {
            end = e.locationInWindow
            let sx = min(start!.x, end!.x)
            let ex = max(start!.x, end!.x)
            let sy = min(start!.y, end!.y)
            let ey = max(start!.y, end!.y)
            start = NSPoint(x: sx, y: sy)
            end   = NSPoint(x: ex, y: ey)
            if temporaryPath != nil {
                temporaryPath = nil
            }
        }

        func drawTemp(_ dirtyRect: NSRect) {
            if let path = temporaryPath {
                path.stroke()
            }
        }

        func makeMarking() -> Marking? {
            guard start != nil && end != nil else { return nil }
            return DrawRect(from: start!, to: end!)
        }
    }
}

class DrawableView: NSView {
    var start: NSEvent? = nil
    var end: NSEvent? = nil {
        didSet { self.needsDisplay = true }
    }

    var markings = Array<Marking>()

    var markingStyles = [
        "r": DrawRect.Factory()
    ]

    var currentStyle: MarkingFactory?

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let ov = NSBezierPath(ovalIn: dirtyRect)
        ov.stroke()

        if let style = currentStyle {
            style.drawTemp(dirtyRect)
        }

        for mark in markings {
            mark.draw(dirtyRect)
        }
    }

    override func mouseDown(with event: NSEvent) {
        NSLog("mds -")
        if currentStyle == nil { // TODO lisää oletus paremmin
            NSLog("curStyle<-")
            currentStyle = markingStyles["r"]
        }
        guard start == nil else { return }
        start = event
        end = nil
        currentStyle!.startEvent(event)
    }

    override func mouseUp(with event: NSEvent) {
        guard end == nil else { return }
        end = event
        currentStyle!.endEvent(event)
        if let marking = currentStyle?.makeMarking() {
            markings.append(marking)
        }
        start = nil
        end = nil
    }

    override func mouseDragged(with event: NSEvent) {
        currentStyle!.moveEvent(event)
        self.needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        if currentStyle == nil { // TODO lisää oletus paremming
            NSLog("curStyle<-")
            currentStyle = markingStyles["r"]
        }
        if let keys = event.characters {
            if keys == "-" {
                if markings.count > 0 {
                    markings.removeLast()
                }
                self.needsDisplay = true
         //   } else if pressed in markingStyles {
            } else if markingStyles.keys.contains(keys) {
                currentStyle = markingStyles[keys]
            } else {
                super.keyUp(with: event)
            }
        } else {
            super.keyUp(with: event)
        }
    }
}
