//
//  ButtonView.swift
//  SynoTool
//
//  Created by Piotr on 04/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

@objc class PZButtonView: NSView
{
    typealias OnClickBlock = (_ sender: PZButtonView) -> Void
    
    var isMouseDown: Bool = false
    
    var isInteractionEnabled: Bool = true
    
    var onClickBlock: OnClickBlock? = nil

    var cornerSize: CGFloat
    {
        return 4
    }
    
    var isEnabled: Bool
    {
        get
        {
            return self.isInteractionEnabled
        }
        set(value)
        {
            self.isInteractionEnabled = value
            
            self.needsDisplay = true
        }
    }
    
    var defaultBackgroundColor = NSColor(calibratedWhite: 0.9, alpha: 1.0)
    {
        didSet
        {
            self.needsDisplay = true
        }
    }

    var defaultSymbolColor = NSColor(calibratedWhite: 0.3, alpha: 1.0)
    {
        didSet
        {
            self.needsDisplay = true
        }
    }

    var disabledSymbolColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
    {
        didSet
        {
            self.needsDisplay = true
        }
    }

    var backgroundColor: NSColor?
    {
        if (self.isMouseDown)
        {
            return defaultSymbolColor
        }
        else
        {
            return defaultBackgroundColor
        }
    }
    
    var symbolColor: NSColor?
    {
        if self.isInteractionEnabled == false
        {
            return disabledSymbolColor
        }

        if (self.isMouseDown)
        {
            return defaultBackgroundColor
        }
        else
        {
            return defaultSymbolColor
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
    }
    
    override var allowsVibrancy: Bool
    {
        return false
    }
    
    override var isOpaque: Bool
    {
        return false
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        let rect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)
        
        let bkgPath = NSBezierPath(roundedRect: rect, xRadius: self.cornerSize, yRadius: self.cornerSize)

        if let color = self.backgroundColor
        {
            color.set()

            bkgPath.addClip()
            bkgPath.fill()
        }
        
        //draw symbol
        NSGraphicsContext.saveGraphicsState()
        
        if let symbolColor = self.symbolColor
        {
            symbolColor.setFill()
            symbolColor.setStroke()
        }

        self.drawSymbol(rect)
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
    func drawSymbol(_ rect: NSRect)
    {

    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool
    {
        return true
    }
    
    override func mouseDown(with event: NSEvent)
    {
        if (self.isInteractionEnabled == false)
        {
            return
        }
        
        self.isMouseDown = true
        
        self.needsDisplay = true
    }

    override func mouseUp(with event: NSEvent)
    {
        if (self.isMouseDown == false)
        {
            return
        }
        
        self.isMouseDown = false
        
        self.needsDisplay = true
        
        if let block = self.onClickBlock
        {
            block(self)
        }
    }
}
