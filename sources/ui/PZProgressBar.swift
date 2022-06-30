//
//  PZProgressBar.swift
//  SynoTool
//
//  Created by Piotr on 06.10.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

@objc class PZProgressBar: NSView
{
    private class Bar
    {
        private var frameWidth: CGFloat = 0
        private var frameHeight: CGFloat = 0
        
        private var barValue: Int = 0
        private var maxBarValue: Int = 0
        
        var layer: CALayer
        
        var value: Int
        {
            get
            {
                return barValue
            }
            set(value)
            {
                if (value > maxBarValue)
                {
                    barValue = maxBarValue
                }
                else
                {
                    barValue = value
                }
                
                let barFrameWidth = self.valueToWidth(value: barValue)
                
                self.set(barFrameWidth: barFrameWidth, duration: 1)
            }
        }
        
        var maxValue: Int
        {
            get
            {
                return maxBarValue
            }
            set(value)
            {
                maxBarValue = value
            }
        }
        
        var percentValue: Int
        {
            let step: Double = Double(self.maxValue) / Double(100)
            
            return Int(step * Double(self.value))
        }
        
        private var valueStep: Double
        {
            if (self.maxBarValue == 0)
            {
                return 0
            }
            
            return Double(self.frameWidth) / Double(self.maxBarValue)
        }

        init()
        {
            self.layer = CALayer()
            self.layer.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
            self.layer.zPosition = 0
        }
        
        func reset(frameWidth: CGFloat, frameHeight: CGFloat)
        {
            self.frameWidth = frameWidth
            self.frameHeight = frameHeight
            
            self.layer.frame = NSRect(x: 0, y: 0, width: 0, height: self.frameHeight)
        }

        private func valueToWidth(value: Int) -> CGFloat
        {
            return CGFloat(valueStep * Double(barValue))
        }
        
        private func set(barFrameWidth: CGFloat, duration: CFTimeInterval)
        {
            DispatchQueue.main.async
            {
                [weak self] in
                
                if let this = self
                {
                    CATransaction.begin()
            
                    CATransaction.setAnimationDuration(duration)
            
                    this.layer.frame = NSRect(x: 0, y: 0, width: barFrameWidth, height: this.frameHeight)
            
                    CATransaction.commit()
                }
            }
        }
    }

    let defaultBkgColor = NSColor(calibratedRed: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
    let defaultBarColor = NSColor(calibratedRed: 0, green: 0.9, blue: 0.5, alpha: 1.0)
    
    var bkgColor: NSColor? = NSColor(calibratedRed: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
    {
        didSet
        {
            if let layer = self.layer
            {
                let color = self.bkgColor == nil ? self.defaultBkgColor : self.bkgColor!

                layer.backgroundColor = color.cgColor

                self.needsDisplay = true
            }
        }
    }
    
    var barColor: NSColor?
    
    private let bar: Bar = Bar()
    
    var barColor050: NSColor = NSColor(calibratedRed: 0, green: 0.9, blue: 0.5, alpha: 1.0)
    var barColor075: NSColor = NSColor(calibratedRed: 1.0, green: 0.75, blue: 0.5, alpha: 1.0)
    var barColor100: NSColor = NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)
    
    var value: Int
    {
        get
        {
            return self.bar.value
        }
        set(value)
        {
            self.bar.value = value
            
            updateBarColor()
        }
    }
    
    var maxValue: Int
    {
        get
        {
            return self.bar.maxValue
        }
        set(value)
        {
            self.bar.maxValue = value
            
            updateBarColor()
        }
    }

    var percentValue: Int
    {
        return self.bar.percentValue
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        initializeLayers()
    }
    
    private func initializeLayers()
    {
        self.wantsLayer = true
    
        bar.reset(frameWidth:self.frame.width, frameHeight: self.frame.height)

        if let layer = self.layer
        {
            layer.addSublayer(bar.layer)
        
            let bkgColor = self.bkgColor == nil ? self.defaultBkgColor : self.bkgColor!
        
            layer.backgroundColor = bkgColor.cgColor
        
            self.updateBarColor()
        }
    }
    
    private func updateBarColor()
    {
        var barColor = self.barColor == nil ? self.defaultBarColor : self.barColor!
        
        if percentValue <= 100
        {
            barColor = barColor100
        }

        if percentValue <= 75
        {
            barColor = barColor075
        }

        if percentValue <= 50
        {
            barColor = barColor050
        }
        
        DispatchQueue.main.async
        {
            [weak self] in
                
            if let this = self
            {

                this.bar.layer.backgroundColor = barColor.cgColor
            }
        }
    }
    
    private var animTestTimer: Timer?
    static private var animTestTimerIndex = 0
    
    func runAnimTestTimer()
    {
        let onAnimTimerSelector = #selector(onAnimTestTimerEvent)

        DispatchQueue.main.async
        {
            [weak self] in

            if let this = self
            {
                this.animTestTimer = Timer(timeInterval: 0.5, target: this, selector: onAnimTimerSelector, userInfo: nil, repeats: true)
    
                RunLoop.main.add(this.animTestTimer!, forMode: RunLoopMode.commonModes)
            }
        }
    }

    @objc private func onAnimTestTimerEvent()
    {
        DispatchQueue.main.async
        {
            [weak self] in

            if let this = self
            {
                this.value = 50
                
                PZProgressBar.animTestTimerIndex += 10
            }
        }
    }
    
}
