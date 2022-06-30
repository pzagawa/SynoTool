//
//  PZSynoFileStationInfoObject.swift
//  testSynoMount
//
//  Created by Piotr on 31.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoFileStationInfoObject: PZSynoObject
{
    private var hostname: String?
    private var is_manager: Bool?
    private var support_virtual_protocol: [String]?
    private var uid: Int?
    
    var hostNameText: String
    {
        return self.hostname == nil ? "" : self.hostname!
    }
    
    var isManager: Bool
    {
        if (self.is_manager == nil)
        {
            return false
        }
        
        return (self.is_manager == true)
    }
    
    var supportVirtualProtocol: [String]
    {
        if (self.support_virtual_protocol == nil)
        {
            return [String()]
        }
        
        return support_virtual_protocol!
    }
    
    var uidValue: Int
    {
        if (self.uid == nil)
        {
            return 0
        }
        
        return self.uid!
    }
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        self.hostname = dataObject["hostname"] as? String
        self.is_manager = dataObject["is_manager"] as? Bool
        self.support_virtual_protocol = dataObject["support_virtual_protocol"] as? [String]
        self.uid = dataObject["uid"] as? Int
    }

    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        let hostname: String = self.hostname == nil ? "<null>" : self.hostname!
        let is_manager: String = self.is_manager == nil ? "<null>" : String(self.is_manager!)
        let uid: String = self.uid == nil ? "<null>" : String(self.uid!)
        
        return "hostname:\(hostname) is_manager:\(is_manager) uid:\(uid)"
    }

}
