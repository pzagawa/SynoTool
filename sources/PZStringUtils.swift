//
//  PZStringUtils.swift
//  SynoTool
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZStringUtils
{
    static var appShortVersionString: String
    {
        if let infoData: [String: Any?] = Bundle.main.infoDictionary
        {
            if let value: Any? = infoData["CFBundleShortVersionString"]
            {
                if value is String
                {
                    return value as! String
                }
            }
        }
        
        return "<unknown appShortVersionString>"
    }

    static var appBuildRevisionString:String
    {
        if let infoData: [String: Any?] = Bundle.main.infoDictionary
        {
            if let value: Any? = infoData["CFBundleVersion"]
            {
                if value is String
                {
                    return value as! String
                }
            }
        }
        
        return "<unknown appBuildRevisionString>"
    }

    static var sysVersion: String
    {
        let version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
}
