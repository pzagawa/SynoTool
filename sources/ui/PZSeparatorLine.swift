//
//  PZSeparatorLine.swift
//  SynoTool
//
//  Created by Piotr on 06.10.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZSeparatorLine: NSView
{
    private class LineSection
    {
        weak var parentRef: PZSeparatorLine?
        let sectionIndex: Int
        let initWidth: CGFloat
        
        private var x: CGFloat = 0
        private var width: CGFloat = 0
        private var height: CGFloat = 0
        
        private var layerInstance: CALayer!
        
        var isHidden: Bool
        {
            if (self.x == -initWidth)
            {
                return true
            }

            return false
        }
        
        init(parentRef: PZSeparatorLine, sectionIndex: Int, width: CGFloat)
        {
            self.parentRef = parentRef
            self.sectionIndex = sectionIndex
            self.initWidth = width
        }
        
        func layer() -> CALayer
        {
            if (layerInstance == nil)
            {
                self.layerInstance = CALayer()

                self.layerInstance.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
                self.layerInstance.zPosition = 0
            }

            return layerInstance
        }
        
        func setShadow()
        {
            if (layerInstance != nil)
            {
                self.layerInstance.shadowOpacity = 1.0
                self.layerInstance.shadowColor = NSColor.black.cgColor
                self.layerInstance.shadowRadius = 10
                self.layerInstance.shadowOffset = CGSize(width: 0, height: 0)
            }
        }
        
        func initialize(height: CGFloat)
        {
            self.x = -initWidth
            self.width = initWidth
            self.height = height
            
            if (layerInstance != nil)
            {
                self.layerInstance.frame = NSRect(x: self.x, y: 0, width: self.width, height: self.height)
            }
        }
        
        var isMinAnimCompleted: Bool = true
        var isMaxAnimCompleted: Bool = true
        
        private func animate(x: CGFloat, duration: CFTimeInterval, completion: @escaping () -> Void)
        {
            if (layerInstance != nil)
            {
                CATransaction.begin()
                
                CATransaction.setAnimationDuration(duration)
                
                CATransaction.setCompletionBlock({ completion() })
                
                self.layerInstance.frame = NSRect(x: x, y: 0, width: self.width, height: self.height)
                
                CATransaction.commit()
            }
        }
        
        func animateMin(frameWidth: CGFloat, duration: CFTimeInterval)
        {
            if (self.isMinAnimCompleted == false)
            {
                return
            }
            
            self.isMinAnimCompleted = false
            
            let x = -self.initWidth
            self.animate(x: x, duration: duration)
            {
                [weak self] in
                
                self?.isMinAnimCompleted = true
            }
        }

        func animateMax(frameWidth: CGFloat, duration: CFTimeInterval)
        {
            if (self.isMaxAnimCompleted == false)
            {
                return
            }
            
            self.isMaxAnimCompleted = false

            let x = frameWidth
            self.animate(x: x, duration: duration)
            {
                [weak self] in

                self?.isMaxAnimCompleted = true
            }
        }
    }
    
    private let maxSectionIndex = 32
    private var sections: [LineSection]  = []
    
    private let defaultBkgColor = NSColor(calibratedRed: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
    private let defaultSectionColor = NSColor(calibratedRed: 0, green: 0.4, blue: 0.8, alpha: 1.0)

    private let errorBkgColor = NSColor(calibratedRed: 1.0, green: 0.7, blue: 0.9, alpha: 1.0)
    private let errorSectionColor = NSColor(calibratedRed: 0.8, green: 0.0, blue: 0.4, alpha: 1.0)

    private var bkgColor: NSColor?
    private var sectionColor: NSColor?
    
    var isError: Bool
    {
        get
        {
            return (bkgColor == errorBkgColor)
        }
        set(value)
        {
            bkgColor = value ? errorBkgColor : defaultBkgColor
            sectionColor = value ? errorSectionColor : defaultSectionColor
            
            self.updateColors()
        }
    }
    
    var isAllSectionsHidden: Bool
    {
        for section in self.sections
        {
            if (section.isHidden == false)
            {
                return false
            }
        }

        return true
    }

    var isAllSectionsMinAnimCompleted: Bool
    {
        for section in self.sections
        {
            if (section.isMinAnimCompleted == false)
            {
                return false
            }
        }
        
        return true
    }

    var isAllSectionsMaxAnimCompleted: Bool
    {
        var result = true
        
        for section in self.sections
        {
            if (section.isMaxAnimCompleted == false)
            {
                result = false
                break
            }
        }
        
        return result
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)

        for sectionIndex in 1...maxSectionIndex
        {
            let width: CGFloat = 16
            
            self.sections.append(LineSection(parentRef: self, sectionIndex: sectionIndex, width: width))
        }
        
        initializeLayers()
    }
    
    private func initializeLayers()
    {
        self.isError = true
        
        self.wantsLayer = true

        for section in self.sections
        {
            self.layer?.addSublayer(section.layer())
        }
        
        self.layer?.backgroundColor = bkgColor?.cgColor
        
        let sectionOpacityStep = Float(1) / Float(self.sections.count)
        var sectionOpacity = Float(1)
        
        for section in self.sections
        {
            section.initialize(height: self.frame.height)
            
            section.layer().backgroundColor = sectionColor?.cgColor
            section.layer().opacity = sectionOpacity
            
            sectionOpacity = sectionOpacity - sectionOpacityStep
        }
    }
    
    private func updateColors()
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            if let this = self
            {
                this.layer?.backgroundColor = this.bkgColor?.cgColor
                
                for section in this.sections
                {
                    section.layer().backgroundColor = this.sectionColor?.cgColor
                }
            }
        }
    }
    
    private func animateMin()
    {
        var durationIndex: CFTimeInterval = 1;
        
        for section in self.sections
        {
            let duration = CFTimeInterval(0.5) * durationIndex
            
            section.animateMin(frameWidth: self.frame.width, duration: duration)
            
            durationIndex = durationIndex + 0.05
        }
    }

    private func animateMax()
    {
        var durationIndex: CFTimeInterval = 1;

        for section in self.sections
        {
            let duration = CFTimeInterval(0.5) * durationIndex

            section.animateMax(frameWidth: self.frame.width, duration: duration)

            durationIndex = durationIndex + 0.05
        }
    }

    func setMax()
    {
        if (self.isAllSectionsMinAnimCompleted == false)
        {
            return
        }

        DispatchQueue.main.async
        {
            [weak self] in

            if let this = self
            {
                this.animateMax()
            }
        }
    }
    
    func setMin()
    {
        if (self.isAllSectionsMaxAnimCompleted == false)
        {
            return
        }

        DispatchQueue.main.async
        {
            [weak self] in

            if let this = self
            {
                this.animateMin()
            }
        }
    }
    
    func tick()
    {
        setMax()
        
        let time = DispatchTime.now() + 0.9
        
        DispatchQueue.global().asyncAfter(deadline: time)
        {
            [weak self] in
            
            self?.setMin()
        }
    }

}
