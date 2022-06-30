//
//  PZMainBackgroundView.swift
//  SynoTool
//
//  Created by Piotr on 03/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZMainBackgroundView: NSView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
    }
    
    override var allowsVibrancy: Bool
    {
        return false
    }
    
    override var isOpaque: Bool
    {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        let rect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)
        
        let bkgPath = NSBezierPath(rect: rect)
        
        let bkgColor = NSColor.white
        
        bkgColor.set()
        
        bkgPath.fill()
    }
    
}
