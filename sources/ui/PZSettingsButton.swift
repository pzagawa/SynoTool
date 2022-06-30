//
//  SettingsButton.swift
//  SynoTool
//
//  Created by Piotr on 05/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZSettingsButton: PZButtonView
{
    override var backgroundColor: NSColor?
    {
        return nil
    }
    
    override var symbolColor: NSColor?
    {
        return self.isMouseDown ? NSColor.secondaryLabelColor : NSColor.labelColor
    }

    override func drawSymbol(_ rect: NSRect)
    {
        NSBezierPath.setDefaultLineWidth(2)

        let symbolWidth = CGFloat(18)
        let symbolHeight = CGFloat(17)
        
        let x = (rect.width * CGFloat(0.5)) - (symbolWidth * CGFloat(0.5))
        let y = CGFloat(Int((rect.height * 0.5)))
        
        let lineSpace = CGFloat(Int(symbolHeight / 3))
        
        let point1S = NSPoint(x: x, y: y);
        let point1E = NSPoint(x: x + symbolWidth, y: y);
        
        NSBezierPath.strokeLine(from: point1S, to: point1E)
        
        let point2S = NSPoint(x: x, y: y - lineSpace);
        let point2E = NSPoint(x: x + symbolWidth, y: y - lineSpace);
        
        NSBezierPath.strokeLine(from: point2S, to: point2E)
        
        let point3S = NSPoint(x: x, y: y + lineSpace);
        let point3E = NSPoint(x: x + symbolWidth, y: y + lineSpace);
        
        NSBezierPath.strokeLine(from: point3S, to: point3E)
    }

}
