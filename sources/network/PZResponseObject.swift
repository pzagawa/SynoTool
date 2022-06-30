//
//  PZResponseObject.swift
//  testSynoMount
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZResponseObject
{
    static let HTTP_STATUS_CODE_ERROR = 0
    static let HTTP_STATUS_CODE_OK = 200

    var url: URL?
    
    let statusCode: Int
    let data: Data?
    let error: Error?
    
    let jsonObject: NSDictionary?
    
    private var updateTime: TimeInterval
    
    var isStatusCodeOK: Bool
    {
        return (self.statusCode == PZResponseObject.HTTP_STATUS_CODE_OK)
    }
    
    var description: String
    {
        return ""
    }

    var statusText: String
    {
        return ""
    }
    
    var errorCode: Int
    {
        return 0
    }
    
    var debugDataText: String?
    {
        if (data == nil)
        {
            return "<no_data>"
        }
        else
        {
            return String(data: self.data!, encoding: String.Encoding.utf8)
        }
    }
    
    var isNetworkError: Bool
    {
        let nsError = self.error as? NSError
        
        if (nsError != nil)
        {
            if (nsError?.domain == NSURLErrorDomain)
            {
                return true
            }
        }
        
        return false;
    }

    init(data: Data?, response: URLResponse?, error: Error?)
    {
        if (response == nil)
        {
            self.url = nil
            self.statusCode = PZResponseObject.HTTP_STATUS_CODE_ERROR
            self.data = data
            self.error = error

            self.jsonObject = nil
        }
        else
        {
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            
            self.url = httpResponse.url!
            self.statusCode = httpResponse.statusCode
            self.data = data
            self.error = error
            
            self.jsonObject = PZResponseObject.decodeJsonObject(data: data)
        }
        
        self.updateTime = Date.timeIntervalSinceReferenceDate
    }
    
    static func decodeJsonObject(data: Data?) -> NSDictionary
    {
        guard data != nil else
        {
            return [:]
        }
        
        let object: Any? = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))

        guard object != nil else
        {
            return [:]
        }

        guard object is NSDictionary else
        {
            return [:]
        }
        
        return object as! NSDictionary
    }
    
    func isValid(lifeTime: Double) -> Bool
    {
        if (Date.timeIntervalSinceReferenceDate < (self.updateTime + lifeTime))
        {
            return true
        }

        return false
    }
    
    func invalidate()
    {
        self.updateTime = 0
    }

}
