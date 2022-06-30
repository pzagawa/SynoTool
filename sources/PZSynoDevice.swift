//
//  PZSynoDevice.swift
//  testSynoMount
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoDevice
{
    private let initializationQueue: OperationQueue
    
    let deviceNumber: UInt
    let deviceUID: String
    let model: PZSynoModel
    
    var authData: PZAuthData?
    {
        didSet(value)
        {
            PZAppEvent.broadcastDeviceAuthDataChanged(deviceUID: deviceUID, deviceNumber: deviceNumber, isAuthDataSet: isAuthDataSet)
            
            if value == nil
            {
                self.model.invalidateAuthObject()
                self.model.invalidateApiInfoObject()
                self.model.invalidateDataObjects()
            }
        }
    }
    
    var isAuthDataSet: Bool
    {
        return (authData != nil)
    }
    
    var deviceName: String?
    {
        return self.model.deviceName
    }
    
    var deviceIdentifier: String
    {
        return "SynoTool:device:\(deviceNumber)"
    }

    enum ConnectionState
    {
        case noConnection
        case networkError
        case synoError(code: Int)
        case statusCode(code: Int)

        case infoApiResponse(version: Int)
        case noInfoApiResponse

        case signedIn
    }

    var connectionState: ConnectionState
    {
        let apiInfoStatus: PZSynoAPI.ApiInfoStatus = self.model.apiInfoStatus
        
        switch apiInfoStatus
        {
        case .notSet:
            return ConnectionState.noConnection
        case .networkError:
            return ConnectionState.networkError
        case .synoError(let code):
            return ConnectionState.synoError(code: code)
        case .statusCode(let code):
            return ConnectionState.statusCode(code: code)
            
        case .infoApiResponse(let version):

            let authStatus: PZSynoAPI.AuthStatus = self.model.authStatus

            switch authStatus
            {
            case .notSet:
                return ConnectionState.infoApiResponse(version: version)
            case .networkError:
                return ConnectionState.networkError
            case .synoError(let code):
                return ConnectionState.synoError(code: code)
            case .statusCode(let code):
                return ConnectionState.statusCode(code: code)
            case .signedIn:
                return ConnectionState.signedIn
            }
            
        case .noInfoApiResponse:
            return ConnectionState.noInfoApiResponse
        }
    }

    var isNetworkError: Bool
    {
        let apiInfoStatus: PZSynoAPI.ApiInfoStatus = self.model.apiInfoStatus
        
        switch apiInfoStatus
        {
        case .notSet:
            return false
        case .networkError:
            return true
        case .synoError:
            return false
        case .statusCode:
            return false
        case .infoApiResponse:
            return false
        case .noInfoApiResponse:
            return false
        }
    }

    var isUserAttentionRequired: Bool
    {
        switch self.connectionState
        {
        case .noConnection:
            return false
        case .networkError:
            return true
        case .synoError(_):
            return true
        case .statusCode(_):
            return true

        case .infoApiResponse(_):
            return false
        case .noInfoApiResponse:
            return true

        case .signedIn:
            return false
        }
    }
    
    init(deviceNumber: UInt)
    {
        self.initializationQueue = OperationQueue.init()
        self.initializationQueue.maxConcurrentOperationCount = 1;
        self.initializationQueue.underlyingQueue = DispatchQueue.global()

        self.deviceNumber = deviceNumber
        self.deviceUID = NSUUID().uuidString

        self.model = PZSynoModel()
        self.model.device = self
        self.model.deviceNumber = self.deviceNumber
        self.model.deviceUID = self.deviceUID
    }

    deinit
    {
        self.model.disableUpdateDataTimer()
    }
    
    var authDataHost: String
    {
        if let authData = self.authData
        {
            return authData.host
        }
        
        return ""
    }
    
    var authDataAccount: String
    {
        if let authData = self.authData
        {
            return authData.account
        }
        
        return ""
    }

    var authDataPassword: String
    {
        if let authData = self.authData
        {
            return authData.password
        }
        
        return ""
    }

    var description: String
    {
        return "NR: \(deviceNumber). UID: \(self.deviceUID). HOST: \(self.authDataHost). ACCOUNT: \(self.authDataAccount)"
    }
    
    private var initializationInProgressValue = false

    var isInitializationInProgress: Bool
    {
        return initializationInProgressValue
    }
    
    func initializeDevice()
    {
        if initializationInProgressValue
        {
            print("[PZSynoDevice] initializeDevice IN PROGRESS..")

            return
        }
        
        initializationInProgressValue = true

        PZAppEvent.broadcastDeviceConnectionStateChanged(deviceUID: deviceUID, deviceNumber: deviceNumber)

        DispatchQueue.global().async
        {
            [weak self] in
            
            if let this = self
            {
                if this.model.isLoggedIn
                {
                    this.model.logoutWithCompletion(completion:
                    {
                        (isSuccess) in

                        this.initWithAuthRequest
                        {
                            this.initializationInProgressValue = false
                        }
                    })
                }
                else
                {
                    this.initWithAuthRequest
                    {
                        this.initializationInProgressValue = false
                    }
                }
            }
        }
    }
    
    private func initWithAuthRequest(completion: @escaping () -> Void)
    {
        let result = self.loadAuthData()
        
        if self.isAuthDataSet
        {
            self.initWithCompletion
            {
                (isSuccess: Bool) in
                
                print("[PZSynoDevice] initWithAuthRequest \(self.deviceNumber) completed: \(isSuccess)")
                
                completion()
            }
        }
        else
        {
            print("[PZSynoDevice] initWithAuthRequest \(self.deviceNumber) authData not set: \(result.description)")

            MainWindowController.showApp()

            completion()
        }
    }
    
    private func initWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        self.initializationQueue.addOperation
        {
            [weak self] in

            if let this = self
            {
                this.model.initWithCompletion(completion: completion)
            }
            else
            {
                completion(false)
            }
        }
    }
    
    func logoutWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        self.initializationQueue.addOperation
        {
            [weak self] in

            if let this = self
            {
                this.model.logoutWithCompletion(completion: completion)
            }
            else
            {
                completion(false)
            }
        }
    }

    func isBusy() -> Bool
    {
        if (self.initializationQueue.operationCount == 0)
        {
            return true
        }
        
        return false;
    }
    
    func waitIfBusy()
    {
        self.initializationQueue.waitUntilAllOperationsAreFinished()
    }

    func reauthenticateWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        self.logoutWithCompletion
        {
            [weak self] (isSuccess) in

            if let this = self
            {
                this.initWithCompletion
                {
                    (isSuccess) in
                    
                    completion(isSuccess)
                }
            }
            else
            {
                completion(false)
            }
        }
    }
    
    private func loadAuthData() -> PZKeychain.Result
    {
        let keychain = PZKeychain(bundleIdentifier: PZAppConsts.mainAppBundleId)

        let result = keychain.getJson(account: self.deviceIdentifier)
        
        if let json = result.json
        {
            self.authData = PZAuthData(json: json)
        }
        else
        {
            self.authData = nil
        }
        
        return result
    }
    
    func setAuthData(host: String, account: String, password: String) -> PZKeychain.Result
    {
        let authData = PZAuthData(host: host, account: account, password: password)
     
        let keychain = PZKeychain(bundleIdentifier: PZAppConsts.mainAppBundleId)
        
        let result = keychain.set(json: authData.json, account: self.deviceIdentifier)

        if result.isSuccess
        {
            self.initializeDevice()
        }
        
        return result
    }

    func removeAuthData() -> PZKeychain.Result
    {
        let keychain = PZKeychain(bundleIdentifier: PZAppConsts.mainAppBundleId)

        let result = keychain.remove(account: self.deviceIdentifier)
        
        if result.isSuccess
        {
            self.initializeDevice()
        }
        
        return result
    }

}
