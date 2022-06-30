//
//  PZAddDownload.swift
//  SynoTool
//
//  Created by Piotr on 29/11/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZAddDownload
{
    private var storyboard: NSStoryboard
    private var windowController: NSWindowController?

    init()
    {
        self.storyboard = NSStoryboard(name: "AddDownload", bundle: nil)
    }
    
    deinit
    {
    }

    func showWith(device: PZSynoDevice)
    {
        if (self.windowController == nil)
        {
            self.windowController = storyboard.instantiateController(withIdentifier: "addDownloadTaskWindowController") as? NSWindowController
            
            if let windowController = self.windowController
            {
                let viewController = windowController.contentViewController as! PZAddDownloadViewController
                
                viewController.device = device
                
                viewController.onCloseBlock =
                {
                    [weak self] in
                    
                    if let this = self
                    {
                        NSApplication.shared().stopModal()
                        
                        windowController.close()
                        
                        this.windowController = nil
                    }
                }
                
                windowController.showWindow(windowController)
                
                NSApplication.shared().runModal(for: windowController.window!)
            }
        }
    }
 
}

