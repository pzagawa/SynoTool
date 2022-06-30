//
//  PZSynoApp.swift
//  SynoTool
//
//  Created by Piotr on 18.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoApp
{
    static let sharedInstance = PZSynoApp()

    private var initializeDeviceTimer: Timer?

    private let device: PZSynoDevice = PZSynoDevice(deviceNumber: 1)
    
    var selectedDevice: PZSynoDevice
    {
        return self.device
    }

    init()
    {
    }

    func initializeDevice()
    {
        self.selectedDevice.initializeDevice()
    }

    func logoutFromDevice(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        selectedDevice.logoutWithCompletion
        {
            (isSuccess: Bool) in
            
            completion(isSuccess)
        }
    }
    
    func waitUntilDeviceInitialized()
    {
        selectedDevice.waitIfBusy()
    }
    
    private var isInitializeDeviceTimerEnabled: Bool
    {
        if let timer = self.initializeDeviceTimer
        {
            return timer.isValid
        }
        else
        {
            return false
        }
    }

    func enableInitializeDeviceTimer()
    {
        self.disableInitializeDeviceTimer()
     
        self.initializeDeviceTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true)
        {
            [weak self] (timer) in
            
            self?.onInitializeDeviceTimer()
        }

        print("[PZSynoApp] enableInitializeDeviceTimer ENABLED")
    }
    
    private func disableInitializeDeviceTimer()
    {
        if let timer = self.initializeDeviceTimer
        {
            if timer.isValid
            {
                timer.invalidate()
            }
            
            self.initializeDeviceTimer = nil
            
            print("[PZSynoApp] disableInitializeDeviceTimer DISABLED")
        }
    }

    private func isInfoApiResponse(apiInfoStatus: PZSynoAPI.ApiInfoStatus) -> Bool
    {
        switch apiInfoStatus
        {
        case .notSet:
            return false
        case .networkError:
            return false
        case .synoError:
            return false
        case .statusCode:
            return false
        case .infoApiResponse:
            return true
        case .noInfoApiResponse:
            return false
        }
    }
    
    private func onInitializeDeviceTimer()
    {
        let device = self.selectedDevice

        if (isInitializeDeviceTimerEnabled == false)
        {
            print("[PZSynoApp] initialize device timer DISABLED")
            
            return
        }
        
        if device.isInitializationInProgress
        {
            print("[PZSynoApp] initialize device IN PROGRESS..")
            
            return
        }

        if device.model.isLoggedIn
        {
            print("[PZSynoApp] initialize device FINISHED: device is logged in")
            
            disableInitializeDeviceTimer()
            
            return
        }
        
        if device.isAuthDataSet
        {
            //device has not been reachable on app initialization
            if device.model.isLoggedIn == false
            {
                print("[PZSynoApp] initialize device START (connectionState: \(self.selectedDevice.connectionState))")

                //check if host responds (wait for being turned on)
                let host = self.selectedDevice.authDataHost
                
                self.device.model.testHostResponse(host: host)
                {
                    [weak self] (apiInfoStatus: PZSynoAPI.ApiInfoStatus) in

                    print("[PZSynoApp] initialize device HOST RESPONSE: \(apiInfoStatus)")

                    if let this = self
                    {
                        if this.isInfoApiResponse(apiInfoStatus: apiInfoStatus)
                        {
                            print("[PZSynoApp] initialize device IS API RESPONSE")
                            
                            device.initializeDevice()
                        }
                    }
                }
            }
        }
    }

}
