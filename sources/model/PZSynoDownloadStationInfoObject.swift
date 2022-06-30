//
//  PZSynoDownloadStationInfoObject.swift
//  synoToolTest
//
//  Created by Piotr on 13.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoDownloadStationInfoObject: PZSynoObject
{
    var is_manager: Bool?
    var version: Int?
    var version_string: String?
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        self.is_manager = dataObject["is_manager"] as? Bool
        self.version = dataObject["version"] as? Int
        self.version_string = dataObject["version_string"] as? String
    }
    
    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }
    
    override var description: String
    {
        let is_manager: String = self.is_manager == nil ? "<null>" : String(self.is_manager!)
        let version: String = self.version == nil ? "<null>" : String(self.version!)
        let version_string: String = self.version_string == nil ? "<null>" : self.version_string!
        
        return "is_manager:\(is_manager) version:\(version) version_string:\(version_string)"
    }
    
}
