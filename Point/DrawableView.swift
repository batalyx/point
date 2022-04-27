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
    func startEvent(_ e: NSEvent, color: NSColor)
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
    var color: NSColor?

    init(from start: NSPoint, to end: NSPoint, color: NSColor) {
        let rect = NSRect(origin: start,
                      size: NSSize(width: end.x-start.x,
                                   height: abs(end.y-start.y)))
        self.rect = rect //.standardized not needed as screen size window
        self.color = color
    }

    init(withRect r: NSRect) {
        self.rect = r
    }

    func draw(_ dirtyRect: NSRect) {
        if let rect = self.rect {
            color?.set()
            rect.frame(withWidth: 2.0)
            NSColor.black.set()
        }
    }

    class Factory : MarkingFactory {
        var start: NSPoint?
        var end: NSPoint?
        var temporaryPath: NSBezierPath?
        var currentColor:  NSColor?

        func startEvent(_ e:NSEvent, color: NSColor) {
            start = e.locationInWindow
            end = nil
            currentColor = color
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
            return DrawRect(from: start!, to: end!, color: currentColor!)
        }
    }
}

class DrawLine : Marking {
    var start: NSPoint?
    var end: NSPoint?
    var color: NSColor?

    convenience init(from start: NSPoint, to end: NSPoint) {
        self.init(from: start, to: end, color: NSColor.black)
    }

    init(from start: NSPoint, to end: NSPoint, color: NSColor) {
        self.start = start
        self.end = end
        self.color = color
    }

    convenience init(withRect r: NSRect) {
        self.init(withRect: r, color: NSColor.black)
    }

    init(withRect r: NSRect, color: NSColor) {
        self.start = NSPoint(x: r.minX, y: r.minY)
        self.end = NSPoint(x: r.maxX, y: r.maxY)
        self.color = color
    }

    func draw(_ dirtyRect: NSRect) {
        if let start = self.start {
            if let end = self.end {
                self.color?.set()
                let pth = NSBezierPath()
                pth.lineWidth = 2.0
                pth.move(to: start)
                pth.line(to: end)
                pth.stroke()
                NSColor.black.set()
            }
        }
    }

    class Factory : MarkingFactory {
        var start: NSPoint?
        var end: NSPoint?
        var temporaryPath: NSBezierPath?
        var currentColor: NSColor?

        func startEvent(_ e:NSEvent, color: NSColor) {
            start = e.locationInWindow
            end = nil
            temporaryPath = NSBezierPath()
            temporaryPath?.lineWidth = 0.1
            temporaryPath?.move(to: start!)
            currentColor = color
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
            return DrawLine(from: start!, to: end!, color: currentColor!)
        }
    }
}


class DrawPath : Marking {
    var start: NSPoint?
    var end: NSPoint?
    var temporaryPath: NSBezierPath?
    var color: NSColor?

    convenience init(from start: NSPoint, to end: NSPoint, path: NSBezierPath) {
        self.init(from: start, to: end, path: path, color: NSColor.black)
    }

    init(from start: NSPoint, to end: NSPoint, path: NSBezierPath, color: NSColor) {
        self.start = start
        self.end = end
        self.temporaryPath = path
        self.temporaryPath?.lineWidth = 2.0
        self.color = color
    }

    convenience init(withRect r: NSRect) {
        self.init(withRect: r, color: NSColor.black)
    }

    init(withRect r: NSRect, color: NSColor) {
        self.start = NSPoint(x: r.minX, y: r.minY)
        self.end = NSPoint(x: r.maxX, y: r.maxY)
        self.color = color
    }

    func draw(_ dirtyRect: NSRect) {
//        if let start = self.start {
//            if let end = self.end {
//                let pth = NSBezierPath()
//                pth.lineWidth = 2.0
//                pth.move(to: start)
//                pth.line(to: end)
//                pth.stroke()
//            }
//        }
        if let pth = self.temporaryPath {
            color?.set()
            pth.stroke();
            NSColor.black.set()
        }
    }

    class Factory : MarkingFactory {
        var start: NSPoint?
        var end: NSPoint?
        var last: NSPoint?
        var temporaryPath: NSBezierPath?
        var currentColor: NSColor?

        func startEvent(_ e:NSEvent, color: NSColor) {
            start = e.locationInWindow
            last = start
            end = nil
            temporaryPath = NSBezierPath()
            temporaryPath?.lineWidth = 0.5
            temporaryPath?.move(to: start!)
            currentColor = color
        }

        func moveEvent(_ e:NSEvent) {
            end = e.locationInWindow

            if let pth = self.temporaryPath {
                pth.move(to: last!)
                pth.line(to: e.locationInWindow)
                last = e.locationInWindow
            }
        }

        func endEvent(_ e:NSEvent, _ markings: inout [Marking]) {
            end = e.locationInWindow
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
            guard start != nil && end != nil && temporaryPath != nil else { return nil }
            let p = DrawPath(from: start!, to: end!, path: temporaryPath!, color: currentColor!)
            temporaryPath = nil
            return p
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
        "l": DrawLine.Factory(),
        "p": DrawPath.Factory(),
        ] as [String : MarkingFactory]

    var currentStyle: MarkingFactory?

    var currentColor = NSColor.black

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
        currentStyle!.startEvent(event, color: currentColor)
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
            } else if keys == "C" {
                if markings.count > 0 {
                    markings.removeAll()
                }
                self.needsDisplay = true
            } else if keys == "b" {
                currentColor = .black
            } else if keys == "B" {
                currentColor = .blue
            } else if keys == "w" {
                currentColor = .white
            } else if keys == "o" {
                currentColor = .orange
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
