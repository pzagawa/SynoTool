//
//  PZSynoSystemStorageInfoObject.swift
//  testSynoMount
//
//  Created by Piotr on 01.09.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZSynoSystemStorageInfoObject: PZSynoObject
{
    class Volume
    {
        private var desc: String?
        private var name: String?
        private var status: String?
        private var total_size: String?
        private var used_size: String?
        
        init(dataObject: NSDictionary)
        {
            self.desc = dataObject["desc"] as? String
            self.name = dataObject["name"] as? String
            self.status = dataObject["status"] as? String
            self.total_size = dataObject["total_size"] as? String
            self.used_size = dataObject["used_size"] as? String
        }
        
        var json: NSDictionary
        {
            let json = NSMutableDictionary()
            
            json["desc"] = self.desc == nil ? nil : self.desc!
            json["name"] = self.name == nil ? nil : self.name!
            json["status"] = self.status == nil ? nil : self.status!
            json["total_size"] = self.total_size == nil ? nil : self.total_size!
            json["used_size"] = self.used_size == nil ? nil : self.used_size!
            
            return NSDictionary(dictionary: json)
        }

        var volumeTitle: String
        {
            if (self.desc == nil)
            {
                return ""
            }
            
            return self.desc!
        }

        var volumeName: String
        {
            if (self.name == nil)
            {
                return ""
            }
            
            return self.name!
        }
        
        var volumeStatus: String
        {
            if (self.status == nil)
            {
                return ""
            }
            
            return self.status!.uppercased()
        }
        
        var totalSize: UInt
        {
            if (self.total_size == nil)
            {
                return 0
            }
            
            return UInt(self.total_size!) ?? 0
        }
        
        var usedSize: UInt
        {
            if (self.used_size == nil)
            {
                return 0
            }
            
            return UInt(self.used_size!) ?? 0
        }
       
        var totalSizeFormatted: String
        {
            let formatter = ByteCountFormatter()

            let size = self.totalSize
            
            return formatter.string(fromByteCount: Int64(size))
        }

        var usedSizeFormatted: String
        {
            let formatter = ByteCountFormatter()
            
            let size = self.usedSize
            
            return formatter.string(fromByteCount: Int64(size))
        }

        var description: String
        {
            let desc: String = self.desc == nil ? "<null>" : self.desc!
            let name: String = self.name == nil ? "<null>" : self.name!
            let status: String = self.status == nil ? "<null>" : self.status!
            
            return "\(desc) \(name) \(status) used: \(self.usedSizeFormatted) of total: \(self.totalSizeFormatted)"
        }
    }

    var volumeList: [Volume] = []
    
    var countVolumes: Int
    {
        return volumeList.count
    }

    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        let list: NSArray? = dataObject["vol_info"] as? NSArray
        
        if (list != nil)
        {
            for item in list!
            {
                if let volumeObject = item as? NSDictionary
                {
                    let volumeInfo: Volume = Volume(dataObject: volumeObject)
                    
                    self.volumeList.append(volumeInfo)
                }
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
        
        let volumes: [PZSynoSystemStorageInfoObject.Volume] = self.volumeList
        
        for volume: PZSynoSystemStorageInfoObject.Volume in volumes
        {
            lines += "- \(volume.description)\n"
        }
        
        return lines
    }

}
