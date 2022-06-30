//
//  PZConnectionKickButton.swift
//  SynoTool
//
//  Created by Piotr on 07/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZConnectionKickButton: PZButtonView
{
    override var cornerSize: CGFloat
    {
        return 2
    }

    override func drawSymbol(_ rect: NSRect)
    {
        NSBezierPath.setDefaultLineWidth(2)

        let marginX: CGFloat = 5
        let marginY: CGFloat = 5

        let point1S = NSPoint(x: marginX, y: marginY);
        let point1E = NSPoint(x: rect.width - marginX, y: rect.height - marginY);

        NSBezierPath.strokeLine(from: point1S, to: point1E)

        let point2S = NSPoint(x: marginX, y: rect.height - marginY);
        let point2E = NSPoint(x: rect.width - marginX, y: marginY);
        
        NSBezierPath.strokeLine(from: point2S, to: point2E)
    }
    
}
