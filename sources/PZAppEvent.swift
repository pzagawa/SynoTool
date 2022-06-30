//
//  PZAppEvent.swift
//  SynoTool
//
//  Created by Piotr on 24.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

//APP EVENT BROADCASTER
class PZAppEvent
{
    static let EVENT_MODEL_OBJECT_UPDATED = NSNotification.Name("PZAppEvent.EVENT_MODEL_OBJECT_UPDATED")
    static let EVENT_MODEL_OBJECT_REQUEST_STARTED = NSNotification.Name("PZAppEvent.EVENT_MODEL_OBJECT_REQUEST_STARTED")
    static let EVENT_MODEL_OBJECT_REQUEST_COMPLETED = NSNotification.Name("PZAppEvent.EVENT_MODEL_OBJECT_REQUEST_COMPLETED")
    static let EVENT_DEVICE_AUTH_DATA_CHANGED = NSNotification.Name("PZAppEvent.EVENT_DEVICE_AUTH_DATA_CHANGED")
    static let EVENT_DEVICE_CONNECTION_STATE_CHANGED = NSNotification.Name("PZAppEvent.EVENT_DEVICE_CONNECTION_STATE_CHANGED")
    
    static let KEY_DEVICE_UID = "deviceUID"
    static let KEY_DEVICE_NUMBER = "deviceNumber"
    static let KEY_DEVICE_IS_AUTH_DATA_SET = "isAuthDataSet"
    static let KEY_OBJECT_TYPE = "objectType"

    static let sharedInstance = PZAppEvent()
    
    private init()
    {
        
    }
    
    static private func broadcastEvent(name: NSNotification.Name, userInfo: Dictionary<String, Any>)
    {
        let object = PZAppEvent.sharedInstance
        
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
    
    static func broadcastModelObjectUpdated(deviceUID: String, objectType: PZSynoModel.ObjectType)
    {
        let userInfo: Dictionary<String, Any> =
        [
            KEY_DEVICE_UID: deviceUID, KEY_OBJECT_TYPE: objectType,
        ]
        
        broadcastEvent(name: EVENT_MODEL_OBJECT_UPDATED, userInfo: userInfo)
    }
    
    static func broadcastModelObjectRequestStarted(deviceUID: String, objectType: PZSynoModel.ObjectType)
    {
        let userInfo: Dictionary<String, Any> =
        [
            KEY_DEVICE_UID: deviceUID, KEY_OBJECT_TYPE: objectType,
        ]
        
        broadcastEvent(name: EVENT_MODEL_OBJECT_REQUEST_STARTED, userInfo: userInfo)
    }

    static func broadcastModelObjectRequestCompleted(deviceUID: String, objectType: PZSynoModel.ObjectType)
    {
        let userInfo: Dictionary<String, Any> =
        [
            KEY_DEVICE_UID: deviceUID, KEY_OBJECT_TYPE: objectType,
        ]
        
        broadcastEvent(name: EVENT_MODEL_OBJECT_REQUEST_COMPLETED, userInfo: userInfo)
    }

    static func broadcastDeviceAuthDataChanged(deviceUID: String, deviceNumber: UInt, isAuthDataSet: Bool)
    {
        let userInfo: Dictionary<String, Any> =
        [
            KEY_DEVICE_UID: deviceUID, KEY_DEVICE_NUMBER: deviceNumber, KEY_DEVICE_IS_AUTH_DATA_SET: isAuthDataSet
        ]
        
        broadcastEvent(name: EVENT_DEVICE_AUTH_DATA_CHANGED, userInfo: userInfo)
    }

    static func broadcastDeviceConnectionStateChanged(deviceUID: String, deviceNumber: UInt)
    {
        let userInfo: Dictionary<String, Any> =
        [
            KEY_DEVICE_UID: deviceUID, KEY_DEVICE_NUMBER: deviceNumber
        ]

        broadcastEvent(name: EVENT_DEVICE_CONNECTION_STATE_CHANGED, userInfo: userInfo)
    }

}

//APP EVENT OBSERVER
class PZAppEventObserver
{
    private let queue: OperationQueue
    
    private var registeredObservers = [String: Any]()

    init()
    {
        self.queue = OperationQueue.init()
        self.queue.maxConcurrentOperationCount = 1;
        self.queue.underlyingQueue = DispatchQueue.global()
    }

    private func observeEvent(name: NSNotification.Name, completion: @escaping (_ notification: Notification) -> Void)
    {
        if (self.registeredObservers[name.rawValue] != nil)
        {
            //skip adding the same observer twice
            return;
        }
        
        let object = PZAppEvent.sharedInstance

        let observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: self.queue)
        {
            (notification) in

            completion(notification)
        }
        
        self.registeredObservers[name.rawValue] = observer;
    }
    
    func stopObservingEvent(name: NSNotification.Name)
    {
        if let observer = self.registeredObservers[name.rawValue]
        {
            NotificationCenter.default.removeObserver(observer, name: name, object: nil)
        }
    }

    private func userInfoData(userInfo: [AnyHashable: Any]) -> (deviceUID: String?, objectType: PZSynoModel.ObjectType?)
    {
        let deviceUID = userInfo[PZAppEvent.KEY_DEVICE_UID] as? String
        let objectType = userInfo[PZAppEvent.KEY_OBJECT_TYPE] as? PZSynoModel.ObjectType

        return (deviceUID: deviceUID, objectType: objectType)
    }
    
    func modelObjectUpdatedEvent(completion: @escaping (_ deviceUID: String?, _ objectType: PZSynoModel.ObjectType?) -> Void)
    {
        self.observeEvent(name: PZAppEvent.EVENT_MODEL_OBJECT_UPDATED)
        {
            (notification) in

            if let userInfo = notification.userInfo
            {
                let data = self.userInfoData(userInfo: userInfo)
                
                completion(data.deviceUID, data.objectType)
            }
        }
    }

    func modelObjectRequestStartedEvent(completion: @escaping (_ deviceUID: String?, _ objectType: PZSynoModel.ObjectType?) -> Void)
    {
        self.observeEvent(name: PZAppEvent.EVENT_MODEL_OBJECT_REQUEST_STARTED)
        {
            (notification) in
            
            if let userInfo = notification.userInfo
            {
                let data = self.userInfoData(userInfo: userInfo)

                completion(data.deviceUID, data.objectType)
            }
        }
    }

    func modelObjectRequestCompletedEvent(completion: @escaping (_ deviceUID: String?, _ objectType: PZSynoModel.ObjectType?) -> Void)
    {
        self.observeEvent(name: PZAppEvent.EVENT_MODEL_OBJECT_REQUEST_COMPLETED)
        {
            (notification) in
            
            if let userInfo = notification.userInfo
            {
                let data = self.userInfoData(userInfo: userInfo)
                
                completion(data.deviceUID, data.objectType)
            }
        }
    }

    func deviceAuthDataChanged(completion: @escaping (_ deviceUID: String?, _ deviceNumber: UInt?, _ isAuthDataSet: Bool?) -> Void)
    {
        self.observeEvent(name: PZAppEvent.EVENT_DEVICE_AUTH_DATA_CHANGED)
        {
            (notification) in
            
            if let userInfo = notification.userInfo
            {
                let deviceUID = userInfo[PZAppEvent.KEY_DEVICE_UID] as? String
                let deviceNumber = userInfo[PZAppEvent.KEY_DEVICE_NUMBER] as? UInt
                let isAuthDataSet = userInfo[PZAppEvent.KEY_DEVICE_IS_AUTH_DATA_SET] as? Bool
                
                completion(deviceUID, deviceNumber, isAuthDataSet)
            }
        }
    }

    func deviceConnectionStateChanged(completion: @escaping (_ deviceUID: String?, _ deviceNumber: UInt?) -> Void)
    {
        self.observeEvent(name: PZAppEvent.EVENT_DEVICE_CONNECTION_STATE_CHANGED)
        {
            (notification) in
            
            if let userInfo = notification.userInfo
            {
                let deviceUID = userInfo[PZAppEvent.KEY_DEVICE_UID] as? String
                let deviceNumber = userInfo[PZAppEvent.KEY_DEVICE_NUMBER] as? UInt
                
                completion(deviceUID, deviceNumber)
            }
        }
    }

}
