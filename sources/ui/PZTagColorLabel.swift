//
//  PZTagColorLabel.swift
//  SynoTool
//
//  Created by Piotr on 16/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZTagColorLabel: NSTextField
{
    var normalBkgColor = NSColor(calibratedRed: 0.5, green: 0.9, blue: 0.4, alpha: 1.0)
    {
        didSet
        {
            self.bkgColor = self.normalBkgColor
            self.needsDisplay = true
        }
    }
    
    var errorBkgColor = NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)
    {
        didSet
        {
            self.bkgColor = self.errorBkgColor
            self.needsDisplay = true
        }
    }
    
    var nullBkgColor = NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    {
        didSet
        {
            self.bkgColor = self.nullBkgColor
            self.needsDisplay = true
        }
    }
    
    private var bkgColor: NSColor?

    var isError: Bool?
    {
        get
        {
            return (bkgColor == errorBkgColor)
        }
        set(value)
        {
            if let errorValue = value
            {
                bkgColor = errorValue ? errorBkgColor : normalBkgColor
            }
            else
            {
                bkgColor = nullBkgColor
            }

            self.needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        self.initialize()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        self.initialize()
    }
    
    private func initialize()
    {
        self.bkgColor = nullBkgColor;
    }
    
    override var allowsVibrancy: Bool
    {
        return false
    }

    override var isOpaque: Bool
    {
        return false
    }

    override var intrinsicContentSize: NSSize
    {
        get
        {
            let contentHorizontalMargin: CGFloat = 4
            
            let w = super.intrinsicContentSize.width + contentHorizontalMargin
            
            return NSSize(width: w, height: super.intrinsicContentSize.height)
        }
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        let topMargin: CGFloat = 1.5
        
        let rect = NSMakeRect(0, topMargin, self.frame.size.width, self.frame.size.height - topMargin)
        
        let bkgPath = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
        
        bkgPath.addClip()
        
        if let color = self.bkgColor
        {
            color.set()
        }

        bkgPath.fill()
        
        super.draw(dirtyRect)
    }

}
