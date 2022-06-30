//
//  PZSynoEmptyObject.swift
//  SynoTool
//
//  Created by Piotr on 20.09.2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

import Cocoa

class PZSynoEmptyObject: PZSynoObject
{
    required init(dataObject: NSDictionary)
    {
        super.init(dataObject: dataObject)
    }
    
    required init(dataObject: NSArray)
    {
        super.init(dataObject: dataObject)
    }
    
    override var description: String
    {
        return ""
    }
    
}
