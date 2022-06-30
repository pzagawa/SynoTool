//
//  PZEventMonitor.swift
//  SynoTool
//
//  Created by Piotr on 26/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

public class PZEventMonitor
{
    typealias EventHandlerBlock = (NSEvent) -> Void
    
    private var monitor: Any?
    private let mask: NSEventMask
    private let handler: EventHandlerBlock
    
    init(mask: NSEventMask, handler: @escaping EventHandlerBlock)
    {
        self.mask = mask
        self.handler = handler
    }
    
    deinit
    {
        stop()
    }
    
    public func start()
    {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop()
    {
        if monitor != nil
        {
            NSEvent.removeMonitor(monitor!)

            monitor = nil
        }
    }
}
