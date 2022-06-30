//
//  PZSynoResponseObject.swift
//  testSynoMount
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoResponseObject<Object: PZSynoObject>: PZResponseObject
{
    var value: Object?

    init()
    {
        super.init(data: nil, response: nil, error: nil)
        
        self.value = (Object.self as Object.Type).init(dataObject: [:])
    }

    override init(data: Data?, response: URLResponse?, error: Error?)
    {
        super.init(data: data, response: response, error: error)
        
        if (self.isSuccess)
        {
            //CREATE instance by Object type with dictionary
            if (self.dataDictionaryObject != nil)
            {
                self.value = (Object.self as Object.Type).init(dataObject: self.dataDictionaryObject!)
            }
            
            //CREATE instance by Object type with array
            if (self.dataArrayObject != nil)
            {
                self.value = (Object.self as Object.Type).init(dataObject: self.dataArrayObject!)
            }
            
            //CREATE instance by Object type with empty dictionary
            if (self.value == nil)
            {
                self.value = (Object.self as Object.Type).init(dataObject: [:])
            }
        }
    }
    
    var isSuccess: Bool
    {
        guard self.error == nil else
        {
            return false
        }
        
        guard self.jsonObject != nil else
        {
            return false
        }
        
        guard self.jsonObject!["success"] != nil else
        {
            return false
        }
        
        let successValue = self.jsonObject!["success"] as? Bool
        
        if let successBool = successValue
        {
            return successBool
        }
        else
        {
            return false
        }
    }

    override var errorCode: Int
    {
        guard self.jsonObject != nil else
        {
            return 0
        }
        
        let errorObject = self.jsonObject!["error"]

        guard errorObject != nil else
        {
            return 0
        }

        if (errorObject is NSDictionary)
        {
            let errorDictionary: NSDictionary = errorObject as! NSDictionary;
            
            guard errorDictionary["code"] != nil else
            {
                return 0
            }

            let code = errorDictionary["code"] as? Int
            
            if (code == nil)
            {
                return 0
            }
            
            return code!
        }
        
        return 0;
    }
    
    var dataDictionaryObject: NSDictionary?
    {
        guard self.jsonObject != nil else
        {
            return nil
        }

        let dataObject = self.jsonObject!["data"]

        guard dataObject != nil else
        {
            return nil
        }
        
        if (dataObject is NSDictionary)
        {
            return dataObject as? NSDictionary
        }
        
        return nil;
    }

    var dataArrayObject: NSArray?
    {
        guard self.jsonObject != nil else
        {
            return nil
        }
        
        let dataObject = self.jsonObject!["data"]
        
        guard dataObject != nil else
        {
            return nil
        }
        
        if (dataObject is NSArray)
        {
            return dataObject as? NSArray
        }
        
        return nil;
    }

    override var statusText: String
    {
        guard self.error == nil else
        {
            return "Status code (\(self.statusCode)). Error (\(self.error?.localizedDescription)). URL \(self.url)"
        }

        guard self.url != nil else
        {
            return "No data returned"
        }
        
        guard self.isStatusCodeOK else
        {
            return "Status code (\(self.statusCode)). URL \(self.url!)"
        }
        
        guard self.isSuccess else
        {
            let synoErrorText = self.synoErrorText(errorCode: self.errorCode)
            
            return "\(self.errorCode). \(synoErrorText). URL \(self.url!)"
        }

        return "Success"
    }

    func synoErrorText(errorCode: Int) -> String
    {
        switch errorCode
        {
        case 100: return "Unknown error"
        case 101: return "No parameter of API, method or version"
        case 102: return "The requested API does not exist"
        case 103: return "The requested method does not exist"
        case 104: return "The requested version does not support the functionality"
        case 105: return "The logged in session does not have permission"
        case 106: return "Session timeout"
        case 107: return "Session interrupted by duplicate login"
        case 119: return "System error (relogin)"
        default:
            return "Unknown error (\(errorCode))"
        }
    }
    
    static func emptyObject() -> PZSynoResponseObject
    {
        let responseObject = PZSynoResponseObject(data: nil, response: nil, error: nil)
        
        return responseObject
    }

}
