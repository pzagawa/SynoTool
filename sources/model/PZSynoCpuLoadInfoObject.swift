//
//  PZSynoCpuLoadInfoObject.swift
//  testSynoMount
//
//  Created by Piotr on 03.09.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoCpuLoadInfoObject: PZSynoObject
{
    private var system_load: Int?
    private var user_load: Int?
    private var other_load: Int?
    
    var systemLoad: Int
    {
        if let load = self.system_load
        {
            return load
        }
        
        return 0
    }

    var userLoad: Int
    {
        if let load = self.user_load
        {
            return load
        }
        
        return 0
    }

    var ioLoad: Int
    {
        if let load = self.other_load
        {
            return load
        }
        
        return 0
    }

    var systemLoadText: String
    {
        return "\(self.systemLoad)%"
    }

    var userLoadText: String
    {
        return "\(self.userLoad)%"
    }

    var ioLoadText: String
    {
        return "\(self.ioLoad)%"
    }

    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        let cpuObject: NSDictionary? = dataObject["cpu"] as? NSDictionary
        
        if (cpuObject != nil)
        {
            self.system_load = cpuObject!["system_load"] as? Int
            self.user_load = cpuObject!["user_load"] as? Int
            self.other_load = cpuObject!["other_load"] as? Int
        }
    }

    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        let system_load: String = self.system_load == nil ? "<null>" : String(self.system_load!)
        let user_load: String = self.user_load == nil ? "<null>" : String(self.user_load!)
        let other_load: String = self.other_load == nil ? "<null>" : String(self.other_load!)
        
        return "system: \(system_load) user: \(user_load) other: \(other_load)"
    }

}
