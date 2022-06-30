//
//  PZSynoApiInfoObject.swift
//  synoToolTest
//
//  Created by Piotr on 17.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoApiInfoObject: PZSynoObject
{
    class ApiInfoItem
    {
        var name: String?
        var path: String?
        var minApiVersion: Int?
        var maxApiVersion: Int?
        var requestFormat: String?
        
        init()
        {
        }
        
        init(dataObject: NSDictionary)
        {
            self.name = dataObject["apiName"] as? String
            self.path = dataObject["path"] as? String
            self.minApiVersion = dataObject["minVersion"] as? Int
            self.maxApiVersion = dataObject["maxVersion"] as? Int
            self.requestFormat = dataObject["requestFormat"] as? String
        }
        
        var description: String
        {
            let name: String = self.name == nil ? "<null>" : self.name!
            let path: String = self.path == nil ? "<null>" : self.path!
            let minApiVersion: String = self.minApiVersion == nil ? "<null>" : String(self.minApiVersion!)
            let maxApiVersion: String = self.maxApiVersion == nil ? "<null>" : String(self.maxApiVersion!)
            let requestFormat: String = self.requestFormat == nil ? "<null>" : String(self.requestFormat!)
            
            return "apiName:\(name) path:\(path) minApiVersion:\(minApiVersion) maxApiVersion:\(maxApiVersion) requestFormat:\(requestFormat)"
        }
    }
    
    var apiInfoItems: [String: ApiInfoItem] = [:]
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)
        
        let keys = dataObject.allKeys
        
        for key in keys
        {
            let value = dataObject[key]
            
            if (value is NSDictionary)
            {
                let apiInfoItem: ApiInfoItem = ApiInfoItem(dataObject: value as! NSDictionary)

                let name = key as? String
                
                apiInfoItem.name = name
            
                self.apiInfoItems[name!] = apiInfoItem
            }
        }
    }
    
    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        var lines = ""
        
        let values = self.apiInfoItems.values
        
        for apiInfoItem: ApiInfoItem in values
        {
            lines += "- \(apiInfoItem.description)\n"
        }
        
        return lines
    }

}
