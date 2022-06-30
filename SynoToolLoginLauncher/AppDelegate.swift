//
//  AppDelegate.swift
//  SynoToolLoginLauncher
//
//  Created by Piotr on 07/12/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var textView: NSTextView!

    func log(text: String)
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            let attributedString = NSAttributedString(string: "\(text)\n")
            self?.textView.textStorage?.append(attributedString)

            let range = NSMakeRange(Int.max, 0)
            self?.textView.scrollRangeToVisible(range)
            
            print("[AppDelegate] \(text)")
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        log(text: "starting..")
        
        //exit if main app is running
        if self.isMainAppRunning()
        {
            log(text: "main app is already running")
            
            terminateSelf()
            
            return
        }

        //add termination observer
        let selector = #selector(onTerminateNotification)
        let notificationName = Notification.Name(rawValue: PZAppConsts.NOTIFICATION_SYNOTOOL_LOGIN_LAUNCHER_TERMINATE)
        let bundleId = PZAppConsts.loginLauncherBundleId
        
        DistributedNotificationCenter.default().addObserver(self, selector: selector, name: notificationName, object: bundleId, suspensionBehavior: .deliverImmediately)

        //get main app path
        if let mainAppPath = self.mainAppBundlePath()
        {
            //start main app
            log(text: "starting main app: \(mainAppPath)")

            if (NSWorkspace.shared().launchApplication(mainAppPath))
            {
                log(text: "app has been started")
            }
            else
            {
                log(text: "can't launch main app path")

                self.window.setIsVisible(true)
            }
        }
        else
        {
            log(text: "can't get main app path")
            
            self.window.setIsVisible(true)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        log(text: "terminating..")
        
        //remove termination observer
        let notificationName = Notification.Name(rawValue: PZAppConsts.NOTIFICATION_SYNOTOOL_LOGIN_LAUNCHER_TERMINATE)
        let bundleId = PZAppConsts.loginLauncherBundleId

        DistributedNotificationCenter.default().removeObserver(self, name: notificationName, object: bundleId)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return false
    }

    func removeItem(lastItem: String, fromComponents: inout [String]) -> Bool
    {
        if let item = fromComponents.last
        {
            if item.caseInsensitiveCompare(lastItem) == ComparisonResult.orderedSame
            {
                fromComponents.removeLast()
                
                return true
            }
            else
            {
                log(text: "path item: \(lastItem) not found")
            }
        }

        return false
    }
    
    //launcher bundle path:
    //SynoTool.app/Contents/Library/LoginItems/SynoToolLoginLauncher.app
    //
    func mainAppBundlePath() -> String?
    {
        var pathComponents: [String] = Bundle.main.bundleURL.pathComponents

        if self.removeItem(lastItem: "SynoToolLoginLauncher.app", fromComponents: &pathComponents)
        {
            if self.removeItem(lastItem: "LoginItems", fromComponents: &pathComponents)
            {
                if self.removeItem(lastItem: "Library", fromComponents: &pathComponents)
                {
                    if self.removeItem(lastItem: "Contents", fromComponents: &pathComponents)
                    {
                        return NSString.path(withComponents: pathComponents)
                    }
                }
            }
        }

        log(text: "path components: \(pathComponents)")

        return nil
    }
    
    func terminateSelf()
    {
        log(text: "terminateApp")

        NSApplication.shared().terminate(nil)
    }
    
    private func isMainAppRunning() -> Bool
    {
        let list = NSWorkspace.shared().runningApplications
        
        for application in list
        {
            if (application.bundleIdentifier == PZAppConsts.mainAppBundleId)
            {
                return true
            }
        }
        
        return false
    }

    func onTerminateNotification()
    {
        log(text: "onTerminateNotification")

        self.window.close()

        terminateSelf()
    }

}

