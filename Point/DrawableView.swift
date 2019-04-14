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
    func endEvent(_ e: NSEvent, _ markings: inout [Marking]) // TODO [Marking] omaksi protoksi/luokaksi
    func selected() // when key of this factory pressed and this is selected
    func deselected() // when other factory's key is pressed and this is deselected
    func drawTemp(_ dirtyRect: NSRect)
    func makeMarking() -> Marking? // XXX pois, liian jotain, -> endEventin sisälle
}


class DrawRect : Marking {
    var rect: NSRect?
    var start: NSPoint?
    var end: NSPoint?

    init(from start: NSPoint, to end: NSPoint) {
        let rect = NSRect(origin: start,
                      size: NSSize(width: end.x-start.x,
                                   height: fabs(end.y-start.y)))
        self.rect = rect //.standardized not needed as screen size window
    }

    init(withRect r: NSRect) {
        self.rect = r
    }

    func draw(_ dirtyRect: NSRect) {
        if let rect = self.rect {
            rect.frame(withWidth: 2.0)
        }
    }

    class Factory : MarkingFactory {
        var start: NSPoint?
        var end: NSPoint?
        var temporaryPath: NSBezierPath?

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
                pth.appendRect(
                    NSRect(x: (start?.x)!, y: (start?.y)!,
                           width:  e.locationInWindow.x-(start?.x)!,
                           height: e.locationInWindow.y-(start?.y)!))
                //line(to: e.locationInWindow)
            }
        }

        func endEvent(_ e:NSEvent, _ markings: inout [Marking]) {
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

        // when key of this factory pressed and this is selected
        func selected() {

        }

        // when other factory's key is pressed and this is deselected
        func deselected() {

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

class DrawLine : Marking {
    var start: NSPoint?
    var end: NSPoint?

    init(from start: NSPoint, to end: NSPoint) {
        self.start = start
        self.end = end
    }

    init(withRect r: NSRect) {
        self.start = NSPoint(x: r.minX, y: r.minY)
        self.end = NSPoint(x: r.maxX, y: r.maxY)
    }

    func draw(_ dirtyRect: NSRect) {
        if let start = self.start {
            if let end = self.end {
                let pth = NSBezierPath()
                pth.lineWidth = 2.0
                pth.move(to: start)
                pth.line(to: end)
                pth.stroke()
            }
        }
    }

    class Factory : MarkingFactory {
        var start: NSPoint?
        var end: NSPoint?
        var temporaryPath: NSBezierPath?

        func startEvent(_ e:NSEvent) {
            start = e.locationInWindow
            end = nil
            temporaryPath = NSBezierPath()
            temporaryPath?.lineWidth = 0.1
            temporaryPath?.move(to: start!)
        }

        func moveEvent(_ e:NSEvent) {
            end = e.locationInWindow

            if let pth = self.temporaryPath {
                pth.move(to: NSPoint(x: (start?.x)!, y: (start?.y)!))
                pth.line(to: e.locationInWindow)
            }
        }

        func endEvent(_ e:NSEvent, _ markings: inout [Marking]) {
            end = e.locationInWindow
            if temporaryPath != nil {
                temporaryPath = nil
            }
        }

        // when key of this factory pressed and this is selected
        func selected() {

        }

        // when other factory's key is pressed and this is deselected
        func deselected() {

        }

        func drawTemp(_ dirtyRect: NSRect) {
            if let path = temporaryPath {
                path.stroke()
            }
        }

        func makeMarking() -> Marking? {
            guard start != nil && end != nil else { return nil }
            return DrawLine(from: start!, to: end!)
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
        "r": DrawRect.Factory(),
        "l": DrawLine.Factory()
        ] as [String : MarkingFactory]

    var currentStyle: MarkingFactory?

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if let style = currentStyle {
            style.drawTemp(dirtyRect)
        }

        for mark in markings {
            mark.draw(dirtyRect)
        }
    }

    override func mouseDown(with event: NSEvent) {
        if currentStyle == nil { // TODO lisää oletus paremmin
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
        currentStyle!.endEvent(event, &markings)
        if let marking = currentStyle?.makeMarking() { // XXX endEventin sisälle!!!
            markings.append(marking)
        }
        start = nil
        end   = nil
    }

    override func mouseDragged(with event: NSEvent) {
        currentStyle!.moveEvent(event)
        self.needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        if currentStyle == nil { // TODO lisää oletus paremming
            currentStyle = markingStyles["r"]
        }
        if let keys = event.characters {
            if keys == "-" {
                if markings.count > 0 {
                    markings.removeLast()
                }
                self.needsDisplay = true
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
