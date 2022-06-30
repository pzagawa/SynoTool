//
//  PZRequest.swift
//  testSynoMount
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZRequest
{
    static let REQUEST_TIMEOUT: TimeInterval = 20
    static let DATA_REQUEST_TIMEOUT: TimeInterval = 20
    
    static let MAX_RETRY_COUNT:Int = 5
    
    var retryNumber:Int = 0

    static private var requestRetainMap: [String: PZRequest] = [:]
    static private let requestRetainMapLock: NSObject = NSObject()

    private let requestUID: String

    public enum HTTPMethod: String
    {
        case POST
        case GET
        case DELETE
        case PUT
    }

    var userAgentHeader: String
    {
        let appShortVersion = PZStringUtils.appShortVersionString
        let appBuildRevision = PZStringUtils.appBuildRevisionString
        let sysVersion = PZStringUtils.sysVersion
        let locale = NSLocale.current.identifier
        
        return "macOS/\(PZAppConsts.APP_NAME) version: \(appShortVersion); \(appBuildRevision); locale: \(locale); os: \(sysVersion)"
    }
    
    var allHTTPHeaders: [String: String]
    {
        return [
            "User-Agent": self.userAgentHeader,
            "Content-Type": "application/json; charset=UTF-8",
        ]
    }
        
    static var sessionConfiguration: URLSessionConfiguration
    {
        let config: URLSessionConfiguration = URLSessionConfiguration.default;
        
        config.allowsCellularAccess = true
        
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        config.timeoutIntervalForRequest = PZRequest.REQUEST_TIMEOUT
        config.timeoutIntervalForResource = PZRequest.REQUEST_TIMEOUT
        
        config.httpMaximumConnectionsPerHost = 3
        
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never

        config.urlCredentialStorage = nil
        config.urlCache = nil

        return config;
    }

    init()
    {
        self.requestUID = NSUUID().uuidString
    }

    static func retainRequest(request: PZRequest)
    {
        objc_sync_enter(PZRequest.requestRetainMapLock)
        
        PZRequest.requestRetainMap[request.requestUID] = request

        objc_sync_exit(PZRequest.requestRetainMapLock)
    }
    
    static func releaseRequest(request: PZRequest)
    {
        objc_sync_enter(PZRequest.requestRetainMapLock)
        
        PZRequest.requestRetainMap[request.requestUID] = nil
        
        objc_sync_exit(PZRequest.requestRetainMapLock)
    }

    func waitSeconds(seconds: Double)
    {
        let waitObject = DispatchSemaphore(value: 0)

        let time = DispatchTime.now() + seconds

        DispatchQueue.global().asyncAfter(deadline: time)
        {
            waitObject.signal()
        }

        waitObject.wait()
    }
    
    func createRequest(httpMethod: HTTPMethod, url: URL) -> URLRequest
    {
        var request: URLRequest = URLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: PZRequest.DATA_REQUEST_TIMEOUT)
        
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = self.allHTTPHeaders;
        
        if (self.retryNumber == 0)
        {
            print("[PZRequest] requestUrl \(httpMethod.rawValue) \(url)")
        }
        else
        {
            print("[PZRequest] requestUrl RETRY:\(self.retryNumber) \(httpMethod.rawValue) \(url)")
        }
        
        return request;
    }
    
}
