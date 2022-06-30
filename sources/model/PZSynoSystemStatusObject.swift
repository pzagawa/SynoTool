//
//  PZSynoSystemStatusObject.swift
//  testSynoMount
//
//  Created by Piotr on 31.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoSystemStatusObject: PZSynoObject
{
    private var is_disk_wcache_crashed: Bool?
    private var is_system_crashed: Bool?
    private var upgrade_ready: Bool?
    
    var isSystemOK: Bool
    {
        if (self.is_system_crashed == nil)
        {
            return true
        }
        
        return (self.is_system_crashed! == false)
    }
    
    var isDiskOK: Bool
    {
        if (self.is_disk_wcache_crashed == nil)
        {
            return true
        }
        
        return (self.is_disk_wcache_crashed! == false)
    }
    
    var systemStatusText: String
    {
        if (self.is_system_crashed == nil)
        {
            return "SYSTEM"
        }

        return self.isSystemOK ? "SYSTEM OK" : "SYSTEM ERROR"
    }

    var diskStatusText: String
    {
        if (self.is_disk_wcache_crashed == nil)
        {
            return "DISK"
        }

        return self.isDiskOK ? "DISK OK" : "DISK ERROR"
    }

    var isUpgradeReady: Bool
    {
        if (self.upgrade_ready == nil)
        {
            return false
        }
        
        return self.upgrade_ready!
    }
    
    var isStatusSet: Bool
    {
        if (self.is_system_crashed != nil && self.is_disk_wcache_crashed != nil)
        {
            return true
        }
        
        return false
    }
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        self.is_disk_wcache_crashed = dataObject["is_disk_wcache_crashed"] as? Bool
        self.is_system_crashed = dataObject["is_system_crashed"] as? Bool
        self.upgrade_ready = dataObject["upgrade_ready"] as? Bool
    }

    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        let is_disk_wcache_crashed: String = self.is_disk_wcache_crashed == nil ? "<null>" : String(self.is_disk_wcache_crashed!)
        let is_system_crashed: String = self.is_system_crashed == nil ? "<null>" : String(self.is_system_crashed!)
        let upgrade_ready: String = self.upgrade_ready == nil ? "<null>" : String(self.upgrade_ready!)
     
        return "is_disk_wcache_crashed: \(is_disk_wcache_crashed) is_system_crashed: \(is_system_crashed) upgrade_ready: \(upgrade_ready)"
    }

}
