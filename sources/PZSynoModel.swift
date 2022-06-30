//
//  PZSynoModel.swift
//  SynoTool
//
//  Created by Piotr on 18.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoModel
{
    private static let SESSION_NAME: String = "\(PZAppConsts.APP_NAME).Model.Session"
    
    private let synoAPI: PZSynoAPI = PZSynoAPI(sessionName: SESSION_NAME)
    
    //OBJECT TYPE
    enum ObjectType: Int
    {
        case FIRST_ITEM
        
        case fileStationInfo
        case systemStatus
        case systemInfo
        case systemStorageInfo
        case cpuLoadInfo
        
        case connectionsInfo
        
        case downloadStationTaskList
        case downloadStationInfo
        case downloadStationStatistic
        
        case downloadStationTaskCreate
        case downloadStationTaskControl
        
        case LAST_ITEM
        
        static var allValues: [ObjectType]
        {
            var list = [ObjectType]()
            
            for index in ObjectType.FIRST_ITEM.rawValue + 1 ..< ObjectType.LAST_ITEM.rawValue
            {
                if let objectType = ObjectType(rawValue: index)
                {
                    list.append(objectType)
                }
            }
            
            return list
        }
    }
    
    //OBJECTS
    var fileStationInfoObject: PZSynoResponseObject<PZSynoFileStationInfoObject>? = nil
    var systemStatusObject: PZSynoResponseObject<PZSynoSystemStatusObject>? = nil
    var systemInfoObject: PZSynoResponseObject<PZSynoSystemInfoObject>? = nil;
    var systemStorageInfoObject: PZSynoResponseObject<PZSynoSystemStorageInfoObject>? = nil
    var cpuLoadInfoObject: PZSynoResponseObject<PZSynoCpuLoadInfoObject>? = nil
    
    var connectionsInfoObject: PZSynoResponseObject<PZSynoConnectionsInfoObject>? = nil
    
    var downloadStationTaskListObject: PZSynoResponseObject<PZSynoDownloadStationTaskListObject>? = nil
    var downloadStationInfoObject: PZSynoResponseObject<PZSynoDownloadStationInfoObject>? = nil
    var downloadStationStatisticObject: PZSynoResponseObject<PZSynoDownloadStationStatisticObject>? = nil
    
    var downloadStationTaskCreateObject: PZSynoResponseObject<PZSynoEmptyObject>? = nil
    var downloadStationTaskControlObject: PZSynoResponseObject<PZSynoDownloadStationTaskControlObject>? = nil
    //--
    
    weak var device: PZSynoDevice? = nil
    
    private let updateDataQueue: OperationQueue
    private var updateDataTimer: Timer?
    
    private var requestsLocks = Set<ObjectType>()
    private let requestsLocksQueue = DispatchQueue(label: "pl.piotr.zagawa.SynoTool.Model")

    var deviceName: String?
    {
        return self.fileStationInfoObject?.value?.hostNameText
    }

    var deviceNumber: UInt
    {
        get
        {
            return self.synoAPI.deviceNumber
        }
        set
        {
            self.synoAPI.deviceNumber = newValue
        }
    }
    
    var deviceUID: String
    {
        get
        {
            return self.synoAPI.deviceUID
        }
        set
        {
            self.synoAPI.deviceUID = newValue
        }
    }
    

    var isUpdateDataTimerEnabled: Bool
    {
        if let timer = self.updateDataTimer
        {
            return timer.isValid
        }
        else
        {
            return false
        }
    }

    var apiInfoStatus: PZSynoAPI.ApiInfoStatus
    {
        return self.synoAPI.apiInfoStatus
    }
    
    var authStatus: PZSynoAPI.AuthStatus
    {
        return self.synoAPI.authStatus
    }
    
    var downloadStationStatus: PZSynoAPI.DownloadStationStatus
    {
        return self.synoAPI.downloadStationStatus
    }

    var isDownloadStationAccessible: Bool
    {
        return self.synoAPI.isDownloadStationAccessible
    }

    var isLoggedIn: Bool
    {
        return self.synoAPI.isLoggedIn
    }
    
    init()
    {
        self.updateDataQueue = OperationQueue.init()
        self.updateDataQueue.maxConcurrentOperationCount = 1;
        self.updateDataQueue.underlyingQueue = DispatchQueue.global()
    }

    func invalidateAuthObject()
    {
        self.synoAPI.invalidateAuthObject()
    }
    
    func invalidateApiInfoObject()
    {
        self.synoAPI.invalidateApiInfoObject()
    }
    
    func invalidateDataObjects()
    {
        self.fileStationInfoObject = nil
        self.systemStatusObject = nil
        self.systemInfoObject = nil
        self.systemStorageInfoObject = nil
        self.cpuLoadInfoObject = nil
        
        self.connectionsInfoObject = nil
        
        self.downloadStationTaskListObject = nil
        self.downloadStationInfoObject = nil
        self.downloadStationStatisticObject = nil
        
        self.downloadStationTaskCreateObject = nil
        self.downloadStationTaskControlObject = nil
    }

    func initWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        self.apiInfo(device: device!, completion:
        {
            [weak self] (response) in
            
            if let this = self
            {
                if (response.isSuccess)
                {
                    this.loginWithCompletion(completion: completion)
                }
                else
                {
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
        })
    }
    
    func loginWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        self.loginTo(device: device!, completion:
        {
            [weak self] (response) in
            
            if let this = self
            {
                if (response.isSuccess)
                {
                    this.updateData()
                    
                    completion(true)
                }
                else
                {
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
        })
    }
    
    func logoutWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        if (self.isLoggedIn)
        {
            self.logoutFrom(device: device!, completion:
            {
                (response) in
                
                completion(response.isSuccess)
            })
        }
        else
        {
            completion(true)
        }
    }
    
    func signInTestWithCompletion(completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        self.apiInfo(device: device!)
        {
            [weak self] (response) in
            
            if (response.isSuccess)
            {
                if let this = self
                {
                    this.loginTo(device: this.device!)
                    {
                        [weak self] (response) in
                        
                        if (response.isSuccess)
                        {
                            if let this = self
                            {
                                this.logoutFrom(device: this.device!)
                                {
                                    (response) in
                                    
                                    completion(true)
                                }
                            }
                            else
                            {
                                completion(true)
                            }
                        }
                        else
                        {
                            completion(false)
                        }
                    }
                }
                else
                {
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
        }
    }
    
    //Periodic model objects update
    func enableUpdateDataTimer()
    {
        print("[PZSynoModel] enableUpdateDataTimer")

        self.disableUpdateDataTimer()
        
        self.updateDataTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block:
        {
            [weak self] (timer) in
            
            self?.updateDataOnTimer()
        })
    }
    
    func disableUpdateDataTimer()
    {
        if let timer = self.updateDataTimer
        {
            if timer.isValid
            {
                timer.invalidate()
            }

            self.updateDataTimer = nil
            
            print("[PZSynoModel] disableUpdateDataTimer")
        }
    }

    private func updateDataOnTimer()
    {
        if (self.isUpdateDataTimerEnabled == false)
        {
            print("[PZSynoModel] updateDataOnTimer isUpdateDataTimerEnabled: false")
            
            return
        }

        updateData()
    }

    private func updateData()
    {
        if (self.isLoggedIn == false)
        {
            print("[PZSynoModel] updateData isLoggedIn: false")
            
            return
        }
        
        if (self.isReauthenticationRequired)
        {
            print("[PZSynoModel] updateData isReauthenticationRequired")
            
            return
        }

        if let device = self.device
        {
            API_fileStationInfo(device: device)
            API_systemStatus(device: device)
            API_systemInfo(device: device)
            API_systemStorageInfo(device: device)
            API_cpuLoadInfo(device: device)
            API_connectionsInfo(device: device)
            API_downloadStationTaskList(device: device)
            API_downloadStationInfo(device: device)
            API_downloadStationStatistic(device: device)
        }
    }
    
    //LOW LEVEL API
    private func objectWithType(objectType: ObjectType) -> PZResponseObject?
    {
        switch objectType
        {
        case .FIRST_ITEM: return nil
            
        case .fileStationInfo: return fileStationInfoObject
        case .systemStatus: return systemStatusObject
        case .systemInfo: return systemInfoObject
        case .systemStorageInfo: return systemStorageInfoObject
        case .cpuLoadInfo: return cpuLoadInfoObject
            
        case .connectionsInfo: return connectionsInfoObject
            
        case .downloadStationTaskList: return downloadStationTaskListObject
        case .downloadStationInfo: return downloadStationInfoObject
        case .downloadStationStatistic: return downloadStationStatisticObject
            
        case .downloadStationTaskCreate: return downloadStationTaskCreateObject
        case .downloadStationTaskControl: return downloadStationTaskControlObject
            
        case .LAST_ITEM: return nil
        }
    }
    
    private func iterateObjects()
    {
        for objectType in ObjectType.allValues
        {
            let responseObject = objectWithType(objectType: objectType)
            
            print("\(objectType.rawValue). \(objectType). \(responseObject?.statusText)")
        }
    }

    private func modelObjectUpdated(deviceUID: String, responseObject: PZResponseObject, objectType: ObjectType)
    {
        if let device = self.device
        {
            if (self.isReauthenticationRequired)
            {
                self.reauthenticate(device: device, completion:
                {
                    (isSuccess) in
                        
                })
            }
        }
        else
        {
            print("[PZSynoModel] modelObjectUpdated device is null")
        }
    }

    private var isReauthenticationRequired: Bool
    {
        return self.synoAPI.isReauthenticationRequired
    }
    
    private var isReauthenticateInProgress = false
    
    private func reauthenticate(device: PZSynoDevice, completion: @escaping (_ isSuccess: Bool) -> Void)
    {
        if isReauthenticateInProgress
        {
            print("[PZSynoModel] reauthenticate IN PROGRESS..")
            
            return
        }

        isReauthenticateInProgress = true
        
        print("[PZSynoModel] reauthenticate BEGIN")
        
        device.reauthenticateWithCompletion
        {
            [weak self] (isSuccess) in
            
            completion(isSuccess)
            
            print("[PZSynoModel] reauthenticate FINISHED: \(isSuccess)")

            if let this = self
            {
                this.isReauthenticateInProgress = false
            }
        }
    }
    
    private func loginTo(device: PZSynoDevice, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoAuthObject>) -> Void)
    {
        guard let authData = device.authData else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        self.synoAPI.loginTo(authData: authData, completion: completion)
    }
    
    private func logoutFrom(device: PZSynoDevice, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoEmptyObject>) -> Void)
    {
        guard let authData = device.authData else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        self.synoAPI.logoutFrom(authData: authData, completion: completion)
    }
    
    private func apiInfo(device: PZSynoDevice, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoApiInfoObject>) -> Void)
    {
        guard let authData = device.authData else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        self.synoAPI.apiInfo(authData: authData, completion: completion)
    }
    
    func testHostResponse(host: String, completion: @escaping (_ apiInfoStatus: PZSynoAPI.ApiInfoStatus) -> Void)
    {
        self.synoAPI.testHostResponse(host: host, completion: completion)
    }
    
    private func isRequestInProgress(objectType: ObjectType) -> Bool
    {
        var result = false
        
        let _ = self.requestsLocksQueue.sync
        {
            if (requestsLocks.contains(objectType))
            {
                result = true
            }
            else
            {
                result = false
            }
        }
        
        return result
    }
    
    private func requestStarted(deviceUID: String, objectType: ObjectType)
    {
        let _ = self.requestsLocksQueue.sync
        {
            requestsLocks.insert(objectType)
        }
        
        PZAppEvent.broadcastModelObjectRequestStarted(deviceUID: deviceUID, objectType: objectType)
    }
    
    private func requestCompleted(deviceUID: String, objectType: ObjectType)
    {
        let _ = self.requestsLocksQueue.sync
        {
            requestsLocks.remove(objectType)
        }
        
        PZAppEvent.broadcastModelObjectRequestCompleted(deviceUID: deviceUID, objectType: objectType)
    }
    
    private func isValid(object: PZResponseObject?, lifeTime: Double) -> Bool
    {
        if let object = object
        {
            return object.isValid(lifeTime: lifeTime)
        }
        
        return false
    }
    
    //UPDATE REQUEST
    private func updateDataCompletion(deviceUID: String, responseObject: PZResponseObject, objectType: ObjectType)
    {
        self.requestCompleted(deviceUID: deviceUID, objectType: objectType)
        
        self.updateDataQueue.addOperation
        {
            print("[PZSynoModel] updateDataCompletion: \(objectType). DeviceUID: \(deviceUID). Status: \(responseObject.statusText)")
            
            PZAppEvent.broadcastModelObjectUpdated(deviceUID: deviceUID, objectType: objectType)
            
            self.modelObjectUpdated(deviceUID: deviceUID, responseObject: responseObject, objectType: objectType)
        }
    }
    
    private func isSkip(deviceUID: String, object: PZResponseObject?, objectType: ObjectType, lifeTime: Double) -> Bool
    {
        if (self.synoAPI.isReauthenticationRequired)
        {
            self.requestCompleted(deviceUID: deviceUID, objectType: objectType)
            
            print("[PZSynoModel] isSkip/isReauthenticationRequired: \(objectType): \(object?.statusText)")
            
            return true
        }
        
        if (isRequestInProgress(objectType: objectType))
        {
            return true
        }
        
        if (isValid(object: object, lifeTime: lifeTime))
        {
            return true
        }
        
        self.requestStarted(deviceUID: deviceUID, objectType: objectType)
        
        return false
    }
    
    //FILESTATION INFO
    private func API_fileStationInfo(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: fileStationInfoObject, objectType: .fileStationInfo, lifeTime: 60))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.fileStationInfo(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.fileStationInfoObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .fileStationInfo)
        }
    }
    
    //SYSTEM STATUS
    private func API_systemStatus(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: systemStatusObject, objectType: .systemStatus, lifeTime: 30))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.systemStatus(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.systemStatusObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .systemStatus)
        }
    }
    
    //SYSTEM INFO
    private func API_systemInfo(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: systemInfoObject, objectType: .systemInfo, lifeTime: 12))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.systemInfo(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.systemInfoObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .systemInfo)
        }
    }
    
    //SYSTEM STORAGE INFO
    private func API_systemStorageInfo(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: systemStorageInfoObject, objectType: .systemStorageInfo, lifeTime: 6))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.systemStorageInfo(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.systemStorageInfoObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .systemStorageInfo)
        }
    }
    
    //CPU LOAD INFO
    private func API_cpuLoadInfo(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: cpuLoadInfoObject, objectType: .cpuLoadInfo, lifeTime: 2))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.cpuLoadInfo(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.cpuLoadInfoObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .cpuLoadInfo)
        }
    }
    
    //CONNECTIONS
    private func API_connectionsInfo(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: connectionsInfoObject, objectType: .connectionsInfo, lifeTime: 3))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.connectionsInfo(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.connectionsInfoObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .connectionsInfo)
        }
    }
    
    //DOWNLOAD STATION TASK LIST
    private func API_downloadStationTaskList(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: downloadStationTaskListObject, objectType: .downloadStationTaskList, lifeTime: 2))
        {
            return
        }

        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.downloadStationTaskList(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.downloadStationTaskListObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .downloadStationTaskList)
        }
    }
    
    //DOWNLOAD STATION INFO
    private func API_downloadStationInfo(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: downloadStationInfoObject, objectType: .downloadStationInfo, lifeTime: 60))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.downloadStationInfo(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.downloadStationInfoObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .downloadStationInfo)
        }
    }
    
    //DOWNLOAD STATION STATISTIC
    private func API_downloadStationStatistic(device: PZSynoDevice)
    {
        if (self.isSkip(deviceUID: device.deviceUID, object: downloadStationStatisticObject, objectType: .downloadStationStatistic, lifeTime: 3))
        {
            return
        }
        
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.downloadStationStatistic(authData: authData)
        {
            [weak self] (responseObject) in
            
            if (responseObject.isSuccess)
            {
                self?.downloadStationStatisticObject = responseObject
            }
            
            self?.updateDataCompletion(deviceUID: device.deviceUID, responseObject: responseObject, objectType: .downloadStationStatistic)
        }
    }
    
    //KICK CONNECTION
    func API_connectionKick(device: PZSynoDevice, connection: PZSynoConnectionsInfoObject.Connection, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoEmptyObject>) -> Void)
    {
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.connectionKick(authData: authData, connection: connection, completion: completion)
    }
    
    //DOWNLOAD STATION TASK CONTROL
    func API_downloadStationTaskControl(device: PZSynoDevice, controlType: PZSynoAPI.TaskControlType, taskId: String, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoDownloadStationTaskControlObject>) -> Void)
    {
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.downloadStationTaskControl(authData: authData, controlType: controlType, tasksIds: [taskId], completion: completion)
    }
    
    //DOWNLOAD STATION TASK CREATE
    func API_downloadStationTaskCreate(device: PZSynoDevice, uri: String, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoEmptyObject>) -> Void)
    {
        guard let authData = device.authData else
        {
            return
        }
        
        self.synoAPI.downloadStationTaskCreate(authData: authData, uri: uri, completion: completion)
    }

}
