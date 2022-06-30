//
//  PZSynoDownloadStationStatisticObject.swift
//  synoToolTest
//
//  Created by Piotr on 16.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoDownloadStationStatisticObject: PZSynoObject
{
    var speed_download: Int?
    var speed_upload: Int?
    var emule_speed_download: Int?
    var emule_speed_upload: Int?
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)

        self.speed_download = dataObject["speed_download"] as? Int
        self.speed_upload = dataObject["speed_upload"] as? Int
        self.emule_speed_download = dataObject["emule_speed_download"] as? Int
        self.emule_speed_upload = dataObject["emule_speed_upload"] as? Int
    }

    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }

    override var description: String
    {
        let speed_download: String = self.speed_download == nil ? "<null>" : String(self.speed_download!)
        let speed_upload: String = self.speed_upload == nil ? "<null>" : String(self.speed_upload!)
        let emule_speed_download: String = self.emule_speed_download == nil ? "<null>" : String(self.emule_speed_download!)
        let emule_speed_upload: String = self.emule_speed_upload == nil ? "<null>" : String(self.emule_speed_upload!)
        
        return "speed_download:\(speed_download) speed_upload:\(speed_upload) emule_speed_download:\(emule_speed_download) emule_speed_upload:\(emule_speed_upload)"
    }
    
}
