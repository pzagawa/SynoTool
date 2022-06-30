//
//  PZAppPrefs.swift
//  testSynoMount
//
//  Created by Piotr on 27.08.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Cocoa

class PZAppPrefs
{
    static let sharedInstance = PZAppPrefs()

    static let PREFS_PREFIX = "com.piotr.zagawa.\(PZAppConsts.APP_NAME)"
    
    private let KEY_INSTALL_UID: String = "\(PZAppPrefs.PREFS_PREFIX).KEY_INSTALL_UID"
    private let KEY_SYNO_DEVICE: String = "\(PZAppPrefs.PREFS_PREFIX).KEY_SYNO_DEVICE"
    private let KEY_START_AT_LOGIN: String = "\(PZAppPrefs.PREFS_PREFIX).KEY_START_AT_LOGIN"

    var installUID: String?
    {
        return UserDefaults.standard.string(forKey: KEY_INSTALL_UID)
    }
    
    var startAtLogin: Bool
    {
        set
        {
            UserDefaults.standard.set(newValue, forKey: KEY_START_AT_LOGIN)
            UserDefaults.standard.synchronize()
        }
        get
        {
            return UserDefaults.standard.bool(forKey: KEY_START_AT_LOGIN)
        }
    }
    
    init()
    {
        createInstallUID()
    }
    
    func createInstallUID()
    {
        var UID: String? = UserDefaults.standard.string(forKey: KEY_INSTALL_UID)
        
        if UID == nil
        {
            UID = NSUUID().uuidString
            
            UserDefaults.standard.setValue(UID, forKey: KEY_INSTALL_UID)
            UserDefaults.standard.synchronize()
            
            print("[PZAppPrefs] init installUID: \(self.installUID)")
        }
    }

    func prefsKeysWithPrefix(prefix: String) -> [String]
    {
        var keys = [String]()
        
        let dict = UserDefaults.standard.dictionaryRepresentation();
        
        for key:String in dict.keys
        {
            if key.hasPrefix(prefix)
            {
                keys.append(key)
            }
        }
        
        return keys
    }
    
    func prefsDevicesKeys() -> [String]
    {
        return self.prefsKeysWithPrefix(prefix: self.KEY_SYNO_DEVICE)
    }

}
