//
//  MainWindowController.swift
//  SynoTool
//
//  Created by Piotr on 21.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController
{
    typealias Completion = (_ isSuccess: Bool) -> Void

    private static weak var mainAppWindow: NSWindow?
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        MainWindowController.mainAppWindow = self.window
    }
    
    //
    //Info.plist LSUIElement "Application is agent (UIElement)" set to true to hide icon in dock
    //
    override func showWindow(_ sender: Any?)
    {
        //ignored showing window on app start
        //super.showWindow(sender)
    }
    
    static func isAppVisible() -> Bool
    {
        if let window = MainWindowController.mainAppWindow
        {
            return window.isVisible && window.isKeyWindow
        }

        return false
    }
    
    static func showApp()
    {
        if (MainWindowController.isAppVisible())
        {
            return
        }
        
        DispatchQueue.global().async
        {
            DispatchQueue.main.async
            {
                MainWindowController.mainAppWindow?.makeKeyAndOrderFront(nil)
                
                NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
                
                print("[MainWindowController] window SHOWN")
            }
            
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
    }

    static func showAppWithCompletion(completion: @escaping Completion)
    {
        if (MainWindowController.isAppVisible())
        {
            return
        }

        DispatchQueue.global().async
        {
            if let window = MainWindowController.mainAppWindow
            {
                if window.isVisible
                {
                    completion(true)

                    return
                }
            }

            let window = MainWindowController.mainAppWindow

            let center = NotificationCenter.default
            
            let waitObject = DispatchSemaphore(value: 0)

            let observer = center.addObserver(forName: NSNotification.Name.NSWindowDidUpdate, object: window, queue: nil, using:
            {
                (notification) in

                completion(true)
                
                waitObject.signal()
            })
            
            MainWindowController.showApp()
            
            waitObject.wait()
            
            center.removeObserver(observer)
        }
    }
    
    static func hideApp()
    {
        DispatchQueue.global().async
        {
            DispatchQueue.main.async
            {
                let window = MainWindowController.mainAppWindow
                
                window?.close()

                NSApplication.shared().deactivate()
                NSApplication.shared().hide(nil)
                
                print("[MainWindowController] window HIDDEN")
            }

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
    }
    
}
