//
//  PZSynoAPI.swift
//  testSynoMount
//
//  Created by Piotr on 31.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoAPI
{
    //API supported version
    struct SupportedVersion
    {
        var apiName: NAME
        var apiVersion: Int
    }

    //List of versions supported in this API by API name
    static let supportedVersions: [NAME: Int] =
    [
        NAME.API_Info: 1,
        NAME.API_Auth: 6,
        NAME.FileStation_Info: 2,
        NAME.Core_System: 3,
        NAME.Core_System_Status: 1,
        NAME.Core_CurrentConnection: 1,
        NAME.Core_System_Utilization: 1,
        NAME.DownloadStation_Task: 3,
        NAME.DownloadStation_Info: 2,
        NAME.DownloadStation_Statistic: 1,
    ]

    //SYNO api names
    enum NAME: String
    {
        case API_Info
        case API_Auth
        case FileStation_Info
        case Core_System
        case Core_System_Status
        case Core_CurrentConnection
        case Core_System_Utilization
        case DownloadStation_Task
        case DownloadStation_Info
        case DownloadStation_Statistic

        var string: String
        {
            return "SYNO." + self.rawValue.replacingOccurrences(of: "_", with: ".")
        }
        
        var supportedVersion: Int
        {
            return PZSynoAPI.supportedVersions[self]!
        }
    }
    
    var deviceNumber: UInt = 0
    var deviceUID: String = ""

    private let sessionName: String
    private let synoError = PZSynoError()
    
    enum ApiInfoStatus
    {
        case notSet
        case networkError
        case synoError(code: Int)
        case statusCode(code: Int)
        case infoApiResponse(version: Int)
        case noInfoApiResponse
    }
    
    enum AuthStatus
    {
        case notSet
        case networkError
        case synoError(code: Int)
        case statusCode(code: Int)
        case signedIn
    }

    enum DownloadStationStatus
    {
        case notSet
        case networkError
        case synoError(code: Int)
        case statusCode(code: Int)
        case infoApiResponse(version: Int)
        case noInfoApiResponse
    }

    private var apiInfoObject: PZSynoResponseObject<PZSynoApiInfoObject>? = nil
    {
        didSet(value)
        {
            PZAppEvent.broadcastDeviceConnectionStateChanged(deviceUID: deviceUID, deviceNumber: deviceNumber)
        }
    }
    
    private var authObject: PZSynoResponseObject<PZSynoAuthObject>? = nil
    {
        didSet(value)
        {
            PZAppEvent.broadcastDeviceConnectionStateChanged(deviceUID: deviceUID, deviceNumber: deviceNumber)
        }
    }

    init(sessionName: String)
    {
        self.sessionName = sessionName
    }
    
    var apiInfoStatus: ApiInfoStatus
    {
        if let apiInfoObject = self.apiInfoObject
        {
            if apiInfoObject.isSuccess
            {
                //success
                if let apiInfoItem = apiInfoObject.value?.apiInfoItems[PZSynoAPI.NAME.API_Auth.string]
                {
                    if let apiVersion = apiInfoItem.maxApiVersion
                    {
                        return ApiInfoStatus.infoApiResponse(version: apiVersion)
                    }
                    else
                    {
                        return ApiInfoStatus.infoApiResponse(version: 1)
                    }
                }
                else
                {
                    return ApiInfoStatus.noInfoApiResponse
                }
            }
            else
            {
                //failure
                if (apiInfoObject.isStatusCodeOK)
                {
                    return ApiInfoStatus.synoError(code: apiInfoObject.errorCode)
                }
                else
                {
                    if apiInfoObject.error != nil
                    {
                        return ApiInfoStatus.networkError
                    }
                    
                    return ApiInfoStatus.statusCode(code: apiInfoObject.statusCode)
                }
            }
        }
        else
        {
            return ApiInfoStatus.notSet
        }
    }
    
    var authStatus: AuthStatus
    {
        if let authObject = self.authObject
        {
            if authObject.isSuccess
            {
                //success
                return AuthStatus.signedIn
            }
            else
            {
                //failure
                if (authObject.isStatusCodeOK)
                {
                    return AuthStatus.synoError(code: authObject.errorCode)
                }
                else
                {
                    if authObject.error != nil
                    {
                        return AuthStatus.networkError
                    }
                    
                    return AuthStatus.statusCode(code: authObject.statusCode)
                }
            }
        }
        else
        {
            return AuthStatus.notSet
        }
    }
    
    var downloadStationStatus: DownloadStationStatus
    {
        if let apiInfoObject = self.apiInfoObject
        {
            if apiInfoObject.isSuccess
            {
                //success
                if let apiInfoItem = apiInfoObject.value?.apiInfoItems[PZSynoAPI.NAME.DownloadStation_Info.string]
                {
                    if let apiVersion = apiInfoItem.maxApiVersion
                    {
                        return DownloadStationStatus.infoApiResponse(version: apiVersion)
                    }
                    else
                    {
                        return DownloadStationStatus.infoApiResponse(version: 1)
                    }
                }
                else
                {
                    return DownloadStationStatus.noInfoApiResponse
                }
            }
            else
            {
                //failure
                if (apiInfoObject.isStatusCodeOK)
                {
                    return DownloadStationStatus.synoError(code: apiInfoObject.errorCode)
                }
                else
                {
                    if apiInfoObject.error != nil
                    {
                        return DownloadStationStatus.networkError
                    }
                    
                    return DownloadStationStatus.statusCode(code: apiInfoObject.statusCode)
                }
            }
        }
        else
        {
            return DownloadStationStatus.notSet
        }
    }
    
    var isDownloadStationAccessible: Bool
    {
        switch self.downloadStationStatus
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

    var isLoggedIn: Bool
    {
        let sid = self.authObject?.value?.sid
        
        if (sid != nil)
        {
            return true
        }
        
        return false
    }
    
    func invalidateAuthObject()
    {
        self.authObject = nil
    }
    
    func invalidateApiInfoObject()
    {
        self.apiInfoObject = nil
    }

    //REQUEST EXECUTOR
    private func executeRequest<Object: PZSynoObject>(httpMethod: PZRequest.HTTPMethod, authData: PZAuthData, requestUrl: PZSynoRequestUrl, retry: Bool, completion: @escaping (_ responseObject: PZSynoResponseObject<Object>) -> Void)
    {
        let synoRequest = PZSynoRequest<Object>()
        
        synoRequest.request(httpMethod: httpMethod, url: requestUrl.url as URL?, bodyData: Data(), retry: retry)
        {
            (responseObject) in
            
            if (responseObject.isSuccess)
            {
                completion(responseObject)
            }
            else
            {
                self.synoError.checkErrorCode(errorCode: responseObject.errorCode)
                
                print("[PZSynoAPI] executeRequest RESPONSE: \(Object.self) STATUS: \(responseObject.statusText)")
                
                completion(responseObject)
            }
        }
    }

    //API INFO
    func apiInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoApiInfoObject>) -> Void)
    {
        let requestUrl:PZSynoRequestUrl = PZSynoRequestUrl(authData: authData, cgiPath: "query.cgi", apiName: NAME.API_Info.string, apiVersion: 1, apiMethod: "query", sessionId: nil)
        
        let apiNames =
        [
            NAME.API_Info.string,
            NAME.API_Auth.string,
            NAME.FileStation_Info.string,
            NAME.Core_System.string,
            NAME.Core_System_Status.string,
            NAME.Core_CurrentConnection.string,
            NAME.Core_System_Utilization.string,
            NAME.DownloadStation_Task.string,
            NAME.DownloadStation_Info.string,
            NAME.DownloadStation_Statistic.string,
        ]
        
        let apiNamesList = apiNames.joined(separator: ",")
        
        requestUrl.addParam(name: "query", value: apiNamesList)
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: false, completion:
        {
            [weak self] (responseObject: PZSynoResponseObject<PZSynoApiInfoObject>) in
            
            if (responseObject.isSuccess)
            {
                print("[PZSynoAPI] apiInfo RETURNED FROM: \(authData.description)")
            }
            
            self?.apiInfoObject = responseObject
            
            completion(responseObject)
        })
    }

    func testHostResponse(host: String, completion: @escaping (_ apiInfoStatus: ApiInfoStatus) -> Void)
    {
        let authData = PZAuthData(host: host, account: "", password: "")
        
        self.testApiInfo(authData: authData)
        {
            (responseObject: PZSynoResponseObject<PZSynoApiInfoObject>) in
            
            if responseObject.isSuccess
            {
                //success
                if let apiInfoItem = responseObject.value?.apiInfoItems[PZSynoAPI.NAME.API_Auth.string]
                {
                    if let apiVersion = apiInfoItem.maxApiVersion
                    {
                        completion(ApiInfoStatus.infoApiResponse(version: apiVersion))
                    }
                    else
                    {
                        completion(ApiInfoStatus.infoApiResponse(version: 1))
                    }
                }
                else
                {
                    completion(ApiInfoStatus.noInfoApiResponse)
                }
            }
            else
            {
                //failure
                if (responseObject.isStatusCodeOK)
                {
                    completion(ApiInfoStatus.synoError(code: responseObject.errorCode))
                }
                else
                {
                    if responseObject.error == nil
                    {
                        completion(ApiInfoStatus.statusCode(code: responseObject.statusCode))
                    }
                    else
                    {
                        completion(ApiInfoStatus.networkError)
                    }
                }
            }
        }
    }

    //API INFO TEST - for quick testing if NAS device responds
    private func testApiInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoApiInfoObject>) -> Void)
    {
        let requestUrl:PZSynoRequestUrl = PZSynoRequestUrl(authData: authData, cgiPath: "query.cgi", apiName: NAME.API_Info.string, apiVersion: 1, apiMethod: "query", sessionId: nil)
        
        let apiNames = [ NAME.API_Auth.string ]
        
        let apiNamesList = apiNames.joined(separator: ",")
        
        requestUrl.addParam(name: "query", value: apiNamesList)
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: false, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoApiInfoObject>) in

            completion(responseObject)
        })
    }

    //REQUEST URL HELPER
    private func createRequestUrl(authData: PZAuthData, apiName: NAME, apiMethod: String) -> PZSynoRequestUrl?
    {
        guard let apiInfoObject = self.apiInfoObject else
        {
            print("[PZSynoAPI] createRequestUrl error: apiInfoObject is nil. API: \(apiName) not available")
            
            return nil
        }
        
        guard let apiInfoObjectValue = apiInfoObject.value else
        {
            print("[PZSynoAPI] createRequestUrl error: apiInfoObject value is nil. API: \(apiName) not available")
            
            return nil
        }
        
        let sessionId = authObject?.value?.sid
        
        if (sessionId == nil)
        {
            print("[PZSynoAPI] createRequestUrl info: sessionId is not set")
        }
        
        //get api info item for request params
        if let apiInfoItem: PZSynoApiInfoObject.ApiInfoItem = apiInfoObjectValue.apiInfoItems[apiName.string]
        {
            let name = apiInfoItem.name!
            let path = apiInfoItem.path!

            let maxApiVersion = apiInfoItem.maxApiVersion!

            let supportedApiVersion = apiName.supportedVersion

            if (maxApiVersion < supportedApiVersion)
            {
                print("[PZSynoAPI] createRequestUrl error: apiName: \(apiName.string), maxApiVersion: \(maxApiVersion) is less than supportedApiVersion: \(supportedApiVersion)")
            }

            return PZSynoRequestUrl(authData: authData, cgiPath: path, apiName: name, apiVersion: maxApiVersion, apiMethod: apiMethod, sessionId: sessionId)
        }
        else
        {
            print("[PZSynoAPI] createRequestUrl error: ApiInfoItem for API: \(apiName) not found")
            return nil
        }
    }

    var isReauthenticationRequired: Bool
    {
        return self.synoError.isReauthenticationRequired
    }

    //LOGIN
    func loginTo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoAuthObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.API_Auth, apiMethod: "login") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        requestUrl.addParam(name: "account", value: authData.account)
        requestUrl.addParam(name: "passwd", value: authData.password)
        requestUrl.addParam(name: "session", value: sessionName)
        requestUrl.addParam(name: "format", value: "sid")
    
        self.synoError.reset()
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            [weak self] (responseObject: PZSynoResponseObject<PZSynoAuthObject>) in

            if (responseObject.isSuccess)
            {
                print("[PZSynoAPI] loginTo LOGGED IN: \(authData.description)")
            }

            self?.authObject = responseObject
            
            if let this = self
            {
                PZAppEvent.broadcastDeviceConnectionStateChanged(deviceUID: this.deviceUID, deviceNumber: this.deviceNumber)
            }

            //call completion with delay
            let time = DispatchTime.now() + 0.25
            
            DispatchQueue.global().asyncAfter(deadline: time)
            {
                completion(responseObject)
            }
        })
    }

    //LOGOUT
    func logoutFrom(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoEmptyObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.API_Auth, apiMethod: "logout") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        requestUrl.addParam(name: "session", value: sessionName)
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: false, completion:
        {
            [weak self] (responseObject: PZSynoResponseObject<PZSynoEmptyObject>) in
            
            if let this = self
            {
                this.invalidateAuthObject()
                this.invalidateApiInfoObject()
            }

            print("[PZSynoAPI] logoutFrom LOGGED OUT FROM: \(authData.description)")
            
            completion(responseObject)
        })
    }
    
    //FILESTATION INFO
    func fileStationInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoFileStationInfoObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.FileStation_Info, apiMethod: "get") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoFileStationInfoObject>) in
            
            completion(responseObject)
        })
    }
    
    //SYSTEM STATUS
    func systemStatus(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoSystemStatusObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.Core_System_Status, apiMethod: "get") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoSystemStatusObject>) in

            completion(responseObject)
        })
    }
    
    //SYSTEM INFO
    func systemInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoSystemInfoObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.Core_System, apiMethod: "info") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoSystemInfoObject>) in

            completion(responseObject)
        })
    }

    //SYSTEM STORAGE INFO
    func systemStorageInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoSystemStorageInfoObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.Core_System, apiMethod: "info") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        requestUrl.addParam(name: "type", value: "storage")

        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoSystemStorageInfoObject>) in

            completion(responseObject)
        })
    }

    //CPU LOAD INFO
    func cpuLoadInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoCpuLoadInfoObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.Core_System_Utilization, apiMethod: "get") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        requestUrl.addParam(name: "type", value: "current")
        
        //resource ["cpu","memory","network"]
        requestUrl.addParam(name: "resource", value: "[\"cpu\"]")
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoCpuLoadInfoObject>) in

            completion(responseObject)
        })
    }
    
    //CONNECTIONS
    func connectionsInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoConnectionsInfoObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.Core_CurrentConnection, apiMethod: "list") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        requestUrl.addParam(name: "sort_by", value: "time")
        requestUrl.addParam(name: "sort_direction", value: "DESC")
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoConnectionsInfoObject>) in

            completion(responseObject)
        })
    }
    
    //KICK CONNECTION
    func connectionKick(authData: PZAuthData, connection: PZSynoConnectionsInfoObject.Connection, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoEmptyObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.Core_CurrentConnection, apiMethod: "kick_connection") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        if connection.isHttpConnection
        {
            requestUrl.addParam(name: "http_conn", value: "[{\(connection.requestKey)}]")
            requestUrl.addParam(name: "service_conn", value: "[]")
        }
        else
        {
            requestUrl.addParam(name: "http_conn", value: "[]")
            requestUrl.addParam(name: "service_conn", value: "[{\(connection.requestKey)}]")
        }
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoEmptyObject>) in

            completion(responseObject)
        })
    }
    
    //DOWNLOAD STATION TASK LIST
    func downloadStationTaskList(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoDownloadStationTaskListObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.DownloadStation_Task, apiMethod: "list") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }
        
        requestUrl.addParam(name: "additional", value: "transfer")

        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoDownloadStationTaskListObject>) in

            completion(responseObject)
        })
    }

    //DOWNLOAD STATION INFO
    func downloadStationInfo(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoDownloadStationInfoObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.DownloadStation_Info, apiMethod: "getInfo") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoDownloadStationInfoObject>) in

            completion(responseObject)
        })
    }

    //DOWNLOAD STATION STATISTIC
    func downloadStationStatistic(authData: PZAuthData, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoDownloadStationStatisticObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.DownloadStation_Statistic, apiMethod: "getInfo") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoDownloadStationStatisticObject>) in

            completion(responseObject)
        })
    }
    
    //DOWNLOAD STATION TASK CREATE
    func downloadStationTaskCreate(authData: PZAuthData, uri: String, completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoEmptyObject>) -> Void)
    {
        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.DownloadStation_Task, apiMethod: "create") else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        requestUrl.addParam(name: "uri", value: uri)
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoEmptyObject>) in

            completion(responseObject)
        })
    }

    //DOWNLOAD STATION TASK CONTROL
    enum TaskControlType: String
    {
        case Delete
        case Pause
        case Resume
    }

    func downloadStationTaskControl(authData: PZAuthData, controlType: TaskControlType, tasksIds: [String], completion: @escaping (_ responseObject: PZSynoResponseObject<PZSynoDownloadStationTaskControlObject>) -> Void)
    {
        let method = controlType.rawValue

        guard let requestUrl = self.createRequestUrl(authData: authData, apiName: NAME.DownloadStation_Task, apiMethod: method) else
        {
            completion(PZSynoResponseObject.emptyObject())
            return
        }

        let taskIdsList = tasksIds.joined(separator: ",")
        
        requestUrl.addParam(name: "id", value: taskIdsList)

        if (controlType == TaskControlType.Delete)
        {
            requestUrl.addParam(name: "force_complete", value: "false")
        }
        
        self.executeRequest(httpMethod: .GET, authData: authData, requestUrl: requestUrl, retry: true, completion:
        {
            (responseObject: PZSynoResponseObject<PZSynoDownloadStationTaskControlObject>) in

            completion(responseObject)
        })
    }

}
