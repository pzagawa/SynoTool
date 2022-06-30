//
//  MainViewController.swift
//  SynoTool
//
//  Created by Piotr on 18.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController
{
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var connectionStatusLabel: PZTagColorLabel!
    @IBOutlet weak var deviceLabel: NSTextField!
    @IBOutlet weak var setNasDeviceButton: NSButton!
    @IBOutlet weak var removeNasDeviceButton: NSButton!
    @IBOutlet weak var autoStartCheck: NSButton!
    
    private weak var device: PZSynoDevice?
    private var appEventObserver: PZAppEventObserver!
    
    private var isClosedAppWindowWhenUserAttentionRequired: Bool = false

    override var representedObject: Any?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.device = PZSynoApp.sharedInstance.selectedDevice
        
        self.appEventObserver = PZAppEventObserver()
        
        self.appEventObserver.deviceAuthDataChanged
        {
            [weak self] (deviceUID, deviceNumber, isAuthDataSet) in

            self?.updateUiState()
        }
        
        self.appEventObserver.deviceConnectionStateChanged
        {
            [weak self] (deviceUID, deviceNumber) in
            
            self?.updateConnectionStatusLabel()
            
            self?.showAppWindowIfUserAttentionRequired()
        }
        
        self.autoStartCheck.state = AppDelegate.instance.startAtLogin ? NSOnState : NSOffState
    }
    
    private func showAppWindowIfUserAttentionRequired()
    {
        if isClosedAppWindowWhenUserAttentionRequired
        {
            //skip showing window because it was closed intentionally
            return
        }
        
        if let device = device
        {
            if device.isUserAttentionRequired
            {
                print("[MainViewController] showAppWindowIfUserAttentionRequired")
                
                MainWindowController.showApp()
            }
        }
    }

    override func viewWillAppear()
    {
        super.viewWillAppear()
        
        connectionStatusLabel.stringValue = "CONNECTION STATUS"
        connectionStatusLabel.normalBkgColor = NSColor(calibratedWhite: 0.7, alpha: 1.0)
        connectionStatusLabel.isError = false

        updateConnectionStatusLabel();
        updateUiState()
    }
    
    override func viewDidDisappear()
    {
    }
    
    deinit
    {
    }
   
    private func updateConnectionStatusLabel()
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            if let this = self
            {
                if let device = this.device
                {
                    switch device.connectionState
                    {
                    case .noConnection:
                        this.connectionStatusLabel.stringValue = "NO CONNECTION"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedWhite: 0.7, alpha: 1.0)
                        
                    case .networkError:
                        this.connectionStatusLabel.stringValue = "CAN'T CONNECT"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
                    case .synoError(let code):
                        this.connectionStatusLabel.stringValue = "DEVICE STATUS \(code)"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
                    case .statusCode(let code):
                        this.connectionStatusLabel.stringValue = "HOST STATUS CODE \(code)"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)

                    case .infoApiResponse(let version):
                        this.connectionStatusLabel.stringValue = "HOST AUTH VERSION \(version)"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)
                    case .noInfoApiResponse:
                        this.connectionStatusLabel.stringValue = "NO HOST RESPONSE"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
                        
                    case .signedIn:
                        this.connectionStatusLabel.stringValue = "CONNECTED"
                        this.connectionStatusLabel.normalBkgColor = NSColor(calibratedRed: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
                    }
                }
            }
        }
    }
    
    private func updateUiState()
    {
        DispatchQueue.main.async
        {
            [weak self] in
            
            if let this = self
            {
                if let device = this.device
                {
                    let isAuthDataSet = device.isAuthDataSet
                    
                    this.deviceLabel.stringValue = isAuthDataSet ? device.authDataHost : "Device host is not set"
                    this.setNasDeviceButton.isEnabled = (isAuthDataSet == false)
                    this.removeNasDeviceButton.isEnabled = isAuthDataSet
                }
                else
                {
                    this.deviceLabel.stringValue = "Device is not set selected"
                    this.setNasDeviceButton.isEnabled = false
                    this.removeNasDeviceButton.isEnabled = false
                }
            }
        }
    }
    
    @IBAction func onRemoveDeviceButtonClick(_ sender: Any)
    {
        if let device = self.device
        {
            if device.removeAuthData().isSuccess == false
            {
                let text = "Can't remove device auth data from keychain"
                
                AppDelegate.instance.showError(text: text)
            }
            
            updateUiState()
        }
    }

    @IBAction func onQuitButtonClick(_ sender: Any)
    {
        NSApplication.shared().terminate(self)
    }

    @IBAction func onCloseButtonClick(_ sender: Any)
    {
        if let device = device
        {
            if device.isUserAttentionRequired
            {
                isClosedAppWindowWhenUserAttentionRequired = true
            }
        }

        MainWindowController.hideApp()
    }
    
    @IBAction func onAutoStartCheckClick(_ sender: Any)
    {
        if self.autoStartCheck.state == NSOnState
        {
            AppDelegate.instance.startAtLogin = true
        }
        else
        {
            AppDelegate.instance.startAtLogin = false
        }
    }
    
    @IBAction func onUrlHomeButtonClick(_ sender: Any)
    {
        if let url = URL(string: "http://synotool.com")
        {
            NSWorkspace.shared().open(url)
        }
    }
    
}

