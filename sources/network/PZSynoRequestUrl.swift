//
//  PZSynoRequestUrl.swift
//  testSynoMount
//
//  Created by Piotr on 28.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoRequestUrl
{
    private var authData: PZAuthData

    let cgiPath: String
    let apiName: String
    let apiVersion: String
    let apiMethod: String
    
    var sessionId: String?

    private var apiParams: [URLQueryItem] = []
    
    //
    //default format:
    //webapi/<CGI_PATH>?api=<API_NAME>&version=<VERSION>&method=<METHOD>[&<PARAMS>][&_sid=<SID>]
    //
    //example:
    //http://host.com:port/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=all
    //
    var url: URL?
    {
        //create base url
        var url: URL? = authData.urlHost?.appendingPathComponent("webapi", isDirectory: true)

        //add path
        url?.appendPathComponent(self.cgiPath, isDirectory: false)
        
        if (url == nil)
        {
            print("[PZSynoRequestUrl] url is null")
            
            return nil;
        }
        
        //add query
        var urlComponents: URLComponents? = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(NSURLQueryItem(name: "api", value: self.apiName) as URLQueryItem)
        queryItems.append(NSURLQueryItem(name: "version", value: self.apiVersion) as URLQueryItem)
        queryItems.append(NSURLQueryItem(name: "method", value: self.apiMethod) as URLQueryItem)
        
        if (self.sessionId != nil)
        {
            queryItems.append(URLQueryItem(name: "_sid", value: self.sessionId!))
        }
        
        queryItems.append(contentsOf: self.apiParams)
        
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url
    }

    init(authData: PZAuthData, cgiPath: String, apiName: String, apiVersion: Int, apiMethod: String, sessionId: String?)
    {
        self.authData = authData
        
        self.cgiPath = cgiPath
        self.apiName = apiName
        self.apiVersion = String(apiVersion)
        self.apiMethod = apiMethod
        
        self.sessionId = sessionId
    }
    
    func addParam(name: String, value: String?)
    {
        self.apiParams.append(URLQueryItem(name: name, value: value))
    }

}
