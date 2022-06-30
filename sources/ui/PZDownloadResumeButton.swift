//
//  PZDownloadResumeButton.swift
//  SynoTool
//
//  Created by Piotr on 16/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZDownloadResumeButton: PZButtonView
{
    enum State: UInt
    {
        case stopped
        case resume
        case pause
        case done
        case wait
    }

    var buttonState: State = State.wait
    {
        didSet
        {
            self.isInteractionEnabled = (buttonState == State.resume || buttonState == State.pause)
            
            self.needsDisplay = true
        }
    }

    //used to port enum to objc
    var buttonStateRawValue: UInt
    {
        get
        {
            return self.buttonState.rawValue
        }
        set
        {
            if let state = State(rawValue: newValue)
            {
                self.buttonState = state
            }
            else
            {
                self.buttonState = State.stopped
            }
        }
    }

    override var cornerSize: CGFloat
    {
        return 2
    }

    override func drawSymbol(_ rect: NSRect)
    {
        if (self.buttonState == State.resume)
        {
            let marginX: CGFloat = 5
            let marginY: CGFloat = 3

            let offsetX: CGFloat = 1
     
            let path = NSBezierPath()

            path.move(to: NSPoint(x: marginX + offsetX, y: marginY))
            path.line(to: NSPoint(x: rect.width - marginX + offsetX, y: rect.midY))
            path.line(to: NSPoint(x: marginX + offsetX, y: rect.height - marginY))
            path.line(to: NSPoint(x: marginX + offsetX, y: marginY))

            path.close()
            path.fill()
        }

        if (self.buttonState == State.pause)
        {
            let marginX: CGFloat = 6
            let marginY: CGFloat = 4
            
            let path1 = NSBezierPath()
            path1.lineWidth = 2
            path1.move(to: NSPoint(x: marginX, y: marginY))
            path1.line(to: NSPoint(x: marginX, y: rect.height - marginY))
            path1.close()
            path1.stroke()

            let path2 = NSBezierPath()
            path2.lineWidth = 2
            path2.move(to: NSPoint(x: rect.width - marginX, y: marginY))
            path2.line(to: NSPoint(x: rect.width - marginX, y: rect.height - marginY))
            path2.close()
            path2.stroke()
        }

        if (self.buttonState == State.stopped)
        {
            let path1 = NSBezierPath()
            
            path1.appendOval(in: rect.insetBy(dx: 5, dy: 5))
            path1.close()
            path1.fill()
        }

        if (self.buttonState == State.done)
        {
            let marginX: CGFloat = 4
            let marginY: CGFloat = 5

            let offsetX: CGFloat = -1

            let path = NSBezierPath()

            path.move(to: NSPoint(x: marginX, y: rect.midY))
            path.line(to: NSPoint(x: rect.midX + offsetX, y: marginY))
            path.line(to: NSPoint(x: rect.width - marginX, y: rect.height - marginY))

            path.lineWidth = 2
            
            path.miterLimit = 6
            path.lineJoinStyle = NSLineJoinStyle.miterLineJoinStyle

            path.stroke()
        }

        if (self.buttonState == State.wait)
        {
            let circleRect = rect.insetBy(dx: 7, dy: 7)
            
            let path = NSBezierPath()
            
            path.appendOval(in: circleRect.offsetBy(dx: -4, dy: 0))
            path.appendOval(in: circleRect)
            path.appendOval(in: circleRect.offsetBy(dx: +4, dy: 0))
            
            path.close()
            path.fill()
        }
    }
    
}
