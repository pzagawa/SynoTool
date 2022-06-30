//
//  PZSynoAuthObject.swift
//  SynoTool
//
//  Created by Piotr on 20.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Cocoa

class PZSynoAuthObject: PZSynoObject
{
    var sid: String?
    
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)
        
        self.sid = dataObject["sid"] as? String
    }
    
    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }
    
    override var description: String
    {
        let sid: String = self.sid == nil ? "<null>" : self.sid!
        
        return "sid:\(sid)"
    }
    
}
