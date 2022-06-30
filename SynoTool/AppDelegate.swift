//
//  AppDelegate.swift
//  SynoTool
//
//  Created by Piotr on 18.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    private var reportPopover: PZReportPopover!
    private let addDownload = PZAddDownload()
    
    private var isStartedByLoginLauncher: Bool = false
    
    static var instance: AppDelegate
    {
        return NSApplication.shared().delegate as! AppDelegate
    }

    var appInfoText: String
    {
        let appShortVersion = PZStringUtils.appShortVersionString
        let appBuildRevision = PZStringUtils.appBuildRevisionString
        let sysVersion = PZStringUtils.sysVersion
        let locale = NSLocale.current.identifier
        
        return "macOS/\(PZAppConsts.APP_NAME) version \(appShortVersion) build \(appBuildRevision). Locale: \(locale); OS \(sysVersion)"
    }

    func applicationWillFinishLaunching(_ notification: Notification)
    {
        print("[AppDelegate] STARTING \(self.appInfoText)")
        
        self.reportPopover = PZReportPopover()

        PZSynoApp.sharedInstance.enableInitializeDeviceTimer()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        self.isStartedByLoginLauncher = self.isLoginLauncherRunning()
        
        if (self.isStartedByLoginLauncher)
        {
            self.notifyLoginLauncherToTerminate()
        }
        
        PZSynoApp.sharedInstance.initializeDevice()
    }

    func showAddDownloadWith(device: PZSynoDevice)
    {
        self.addDownload.showWith(device: device)
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        //the ONLY valid place to make graceful cleanup

    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return false
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply
    {
        PZSynoApp.sharedInstance.logoutFromDevice
        {
            (isSuccess) in

            sender.reply(toApplicationShouldTerminate: true)
        }
        
        return NSApplicationTerminateReply.terminateLater;
    }

    private func isLoginLauncherRunning() -> Bool
    {
        let list = NSWorkspace.shared().runningApplications
        
        for application in list
        {
            if (application.bundleIdentifier == PZAppConsts.loginLauncherBundleId)
            {
                return true
            }
        }
        
        return false
    }
    
    private func notifyLoginLauncherToTerminate()
    {
        let notificationName = Notification.Name(rawValue: PZAppConsts.NOTIFICATION_SYNOTOOL_LOGIN_LAUNCHER_TERMINATE)
        let bundleId = PZAppConsts.loginLauncherBundleId
        
        DistributedNotificationCenter.default().post(name: notificationName, object: bundleId)
    }
    
    var startAtLogin: Bool
    {
        set
        {
            let bundleId: CFString = PZAppConsts.loginLauncherBundleId as NSString

            if SMLoginItemSetEnabled(bundleId, newValue)
            {
                PZAppPrefs.sharedInstance.startAtLogin = newValue
            }
            else
            {
                let text = newValue ? "Can't add LoginLauncher application to login item list" : "Can't remove LoginLauncher application from login item list"
                
                showError(text: text)
            }
        }
        get
        {
            return PZAppPrefs.sharedInstance.startAtLogin
        }
    }
    
    func showError(text: String)
    {
        DispatchQueue.main.async
        {
            let alert = NSAlert()
            alert.messageText = "SynoTool: error ocurred"
            alert.informativeText = text
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
}

