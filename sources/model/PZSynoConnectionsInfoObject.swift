//
//  PZSynoConnectionsInfoObject.swift
//  testSynoMount
//
//  Created by Piotr on 02.09.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoConnectionsInfoObject: PZSynoObject
{
    class Connection
    {
        private var can_be_kicked: Bool?
        private var descr: String?
        private var from: String?
        private var pid: String?
        private var time: String?
        private var type: String?
        private var user_can_be_disabled: Bool?
        private var who: String?

        var connectionPid: String
        {
            return self.pid ?? ""
        }

        var connectionWho: String
        {
            return self.who ?? ""
        }

        var connectionDescription: String
        {
            return self.descr ?? ""
        }

        var connectionType: String
        {
            return self.type ?? ""
        }

        var connectionFrom: String
        {
            return self.from ?? ""
        }

        var isKickEnabled: Bool
        {
            if let value = self.can_be_kicked
            {
                return value
            }
            
            return false
        }
        
        init(dataObject: NSDictionary)
        {
            self.can_be_kicked = dataObject["can_be_kicked"] as? Bool
            self.descr = dataObject["descr"] as? String
            self.from = dataObject["from"] as? String
            self.pid = dataObject["pid"] as? String
            self.time = dataObject["time"] as? String
            self.type = dataObject["type"] as? String
            self.user_can_be_disabled = dataObject["user_can_be_disabled"] as? Bool
            self.who = dataObject["who"] as? String
        }
        
        var description: String
        {
            let descr: String = self.descr == nil ? "<null>" : self.descr!
            let who: String = self.who == nil ? "<null>" : self.who!
            let type: String = self.type == nil ? "<null>" : self.type!
            let from: String = self.from == nil ? "<null>" : self.from!

            return "\(who) \(type) \(from) (\(descr))"
        }
        
        var isHttpConnection: Bool
        {
            if let typeValue = type
            {
                if typeValue.hasPrefix("HTTP")
                {
                    return true
                }
            }

            return false
        }

        var json: NSDictionary
        {
            let json = NSMutableDictionary()

            json["can_be_kicked"] = self.can_be_kicked == nil ? nil : self.can_be_kicked!
            json["descr"] = self.descr == nil ? nil : self.descr!
            json["from"] = self.from == nil ? nil : self.from!
            json["pid"] = self.pid == nil ? nil : self.pid!
            json["time"] = self.time == nil ? nil : self.time!
            json["type"] = self.type == nil ? nil : self.type!
            json["user_can_be_disabled"] = self.user_can_be_disabled == nil ? nil : self.user_can_be_disabled!
            json["who"] = self.who == nil ? nil : self.who!

            return NSDictionary(dictionary: json)
        }

        var requestKey: String
        {
            let pid = self.pid ?? "null"
            let type = self.type ?? "null"
            let who = self.who ?? "null"
            let from = self.from ?? "null"
            
            return "pid:\(pid),type:\(type),who:\(who),from:\(from)"
        }
    }

    var connectionList: [Connection] = []
    var systime: String?

    var countConnections: Int
    {
        return connectionList.count
    }

    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        let list: NSArray? = dataObject["items"] as? NSArray
        
        if (list != nil)
        {
            for item in list!
            {
                if let connectionObject = item as? NSDictionary
                {
                    let connection:Connection = Connection(dataObject: connectionObject)
                    
                    self.connectionList.append(connection)
                }
            }
        }
        
        self.systime = dataObject["systime"] as? String
    }
    
    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        var lines = ""
        
        let connections: [PZSynoConnectionsInfoObject.Connection] = self.connectionList
        
        for connection: PZSynoConnectionsInfoObject.Connection in connections
        {
            lines += "- \(connection.description)\n"
        }

        return lines
    }

}
