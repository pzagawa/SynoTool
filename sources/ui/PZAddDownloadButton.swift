//
//  PZAddDownloadButton.swift
//  SynoTool
//
//  Created by Piotr on 15/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZAddDownloadButton: PZButtonView
{
    override var cornerSize: CGFloat
    {
        return 2
    }

    override func drawSymbol(_ rect: NSRect)
    {
        NSBezierPath.setDefaultLineWidth(2)
        
        let marginX: CGFloat = 3
        let marginY: CGFloat = 3

        let point1S = NSPoint(x: rect.midX, y: marginY);
        let point1E = NSPoint(x: rect.midX, y: rect.height - marginY);

        NSBezierPath.strokeLine(from: point1S, to: point1E)

        let point2S = NSPoint(x: marginX, y: rect.midY);
        let point2E = NSPoint(x: rect.width - marginX, y: rect.midY);
        
        NSBezierPath.strokeLine(from: point2S, to: point2E)
    }
    
}
