//
//  PZReportPopover.swift
//  SynoTool
//
//  Created by Piotr on 26/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

protocol PZReportPopoverAction: class
{
    func showPopover()
    func closePopover()
    func isPopoverVisible() -> Bool
}

class PZReportPopover: NSObject, NSPopoverDelegate, PZReportPopoverAction
{
    private let statusBarItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    private let popover = NSPopover()
    private let reportStoryboard: NSStoryboard

    private var statusBarButton: NSStatusBarButton?
    private var eventMonitor: PZEventMonitor?
    
    override init()
    {
        self.reportStoryboard = NSStoryboard(name: "Report", bundle: nil)
        
        super.init()
        
        self.popover.delegate = self
        
        //set statusBar button
        if let button = statusBarItem.button
        {
            button.image = NSImage(named: "synotool-statusbaricon")
            button.action = #selector(PZReportPopover.showPopoverButtonAction(sender:))
            button.target = self
            
            self.statusBarButton = button
        }
    }

    deinit
    {
        self.eventMonitor?.stop()
        
        self.statusBarButton = nil
        
        self.popover.delegate = nil
    }
    
    func showPopoverButtonAction(sender: AnyObject?)
    {
        if self.isPopoverVisible()
        {
            self.internalClosePopover()
        }
        else
        {
            self.internalShowPopover()
        }
    }

    private func restartEventMonitor()
    {
        self.eventMonitor?.stop()
        
        self.eventMonitor = PZEventMonitor(mask: [.leftMouseDown, .rightMouseDown])
        {
            [weak self] event in
            
            if let this = self
            {
                if this.isPopoverVisible()
                {
                    this.closePopover()
                }
            }
        }
        
        self.eventMonitor?.start()
    }
    
    public func popoverDidClose(_ notification: Notification)
    {
        self.popover.contentViewController = nil
    }

    private func internalShowPopover()
    {
        if self.isPopoverVisible()
        {
            return
        }
        
        if let reportViewController = self.reportStoryboard.instantiateController(withIdentifier: "reportViewController") as? ReportViewController
        {
            reportViewController.popoverAction = self
            
            self.popover.contentViewController = reportViewController
        
            if let view = self.statusBarButton
            {
                self.popover.show(relativeTo: view.bounds, of: view, preferredEdge: NSRectEdge.minY)

                self.restartEventMonitor()
            }
            else
            {
                print("[PZReportPopover] showPopover statusBarButton view is nil")
            }
        }
        else
        {
            print("[PZReportPopover] showPopover cant instantiate ReportViewController")
        }
    }
    
    private func internalClosePopover()
    {
        self.eventMonitor?.stop()

        self.popover.performClose(self)
    }
    
    func showPopover()
    {
        self.internalShowPopover()
    }
    
    func closePopover()
    {
        if self.isPopoverVisible()
        {
            self.internalClosePopover()
        }
    }

    func isPopoverVisible() -> Bool
    {
        return self.popover.isShown
    }

}
