//
//  PZKeychain.swift
//  SynoTool
//
//  Created by Piotr on 11/12/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZKeychain
{
    private class Query
    {
        //keys for query dictionary
        enum QueryKey
        {
            case SecClass
            case SecAttrAccount
            case SecAttrService
            case SecAttrSynchronizable
            case SecAttrAccessGroup
            case SecAttrAccessible
            case SecMatchLimit
            case SecReturnData
            case SecValueData
            
            var value: String
            {
                switch self
                {
                case .SecClass: return kSecClass as String
                case .SecAttrAccount: return kSecAttrAccount as String
                case .SecAttrService: return kSecAttrService as String
                case .SecAttrSynchronizable: return kSecAttrSynchronizable as String
                case .SecAttrAccessGroup: return kSecAttrAccessGroup as String
                case .SecAttrAccessible: return kSecAttrAccessible as String
                case .SecMatchLimit: return kSecMatchLimit as String
                case .SecReturnData: return kSecReturnData as String
                case .SecValueData: return kSecValueData as String
                }
            }
        }

        //kSecClass values
        enum ItemClass
        {
            case genericPassword
            case internetPassword
            
            var value: String
            {
                switch self
                {
                case .genericPassword: return String(kSecClassGenericPassword)
                case .internetPassword: return String(kSecClassInternetPassword)
                }
            }
        }
        
        //kSecAttrAccessible attribute values
        enum Accessible
        {
            case always
            case whenUnlocked
            case whenUnlockedThisDeviceOnly
            case afterFirstUnlock
            case afterFirstUnlockThisDeviceOnly
            case whenPasscodeSetThisDeviceOnly
            case alwaysThisDeviceOnly

            var value: String
            {
                switch self
                {
                case .always: return String(kSecAttrAccessibleAlways)
                case .whenUnlocked: return String(kSecAttrAccessibleWhenUnlocked)
                case .whenUnlockedThisDeviceOnly: return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
                case .afterFirstUnlock: return String(kSecAttrAccessibleAfterFirstUnlock)
                case .afterFirstUnlockThisDeviceOnly: return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
                case .whenPasscodeSetThisDeviceOnly: return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
                case .alwaysThisDeviceOnly: return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
                }
            }
        }
        
        //kSecMatchLimit attribute values
        enum SearchMatch
        {
            case limitOne
            case limitAll
            
            var value: String
            {
                switch self
                {
                case .limitOne: return String(kSecMatchLimitOne)
                case .limitAll: return String(kSecMatchLimitAll)
                }
            }
        }
        
        //query params
        let itemClass: ItemClass
        let attributeAccount: String
        let attributeService: String
        let attributeSynchronizable: Bool
        
        //optional query params
        var attributeAccessGroup: String?
        var attributeAccessible: Accessible?
        var searchMatchLimit: SearchMatch?
        var returnData: Bool?
        var valueData: Data?
        
        init(itemClass: ItemClass, account: String, service: String, synchronizable: Bool)
        {
            self.itemClass = itemClass
            self.attributeAccount = account
            self.attributeService = service
            self.attributeSynchronizable = synchronizable
        }
        
        var dictionary: CFDictionary
        {
            var query: [String: Any] = [:]
            
            //generic item type
            query[QueryKey.SecClass.value] = self.itemClass.value
            
            //attribute account key
            query[QueryKey.SecAttrAccount.value] = self.attributeAccount
            
            //attribute service key
            query[QueryKey.SecAttrService.value] = self.attributeService
            
            //attribute to allow data sync across devices with iCloud
            query[QueryKey.SecAttrSynchronizable.value] = self.attributeSynchronizable ? kCFBooleanTrue : kCFBooleanFalse
            
            //optional: access group for sharing keychain items between modules
            if let value = self.attributeAccessGroup
            {
                query[QueryKey.SecAttrAccessGroup.value] = value
            }
            
            //optional: when app needs data from keychain
            if let value = self.attributeAccessible
            {
                query[QueryKey.SecAttrAccessible.value] = value.value
            }
            
            //optional: search match limit
            if let value = self.searchMatchLimit
            {
                query[QueryKey.SecMatchLimit.value] = value.value
            }
            
            //optional: bool flag to load item data
            if let value = self.returnData
            {
                query[QueryKey.SecReturnData.value] = value ? kCFBooleanTrue : kCFBooleanFalse
            }
            
            //optional: bool flag to save item data
            if let data = self.valueData
            {
                query[QueryKey.SecValueData.value] = data
            }
            
            return query as CFDictionary
        }
    }
    
    struct Result
    {
        let isSuccess: Bool
        let code: OSStatus
        let message: String
        let data: Data?
        let json: [String: String]?
        
        var codeDescription: String
        {
            if (self.code == 0)
            {
                return ""
            }
            
            if let description = SecCopyErrorMessageString(self.code,nil)
            {
                return "code \(self.code): \(String(description))"
            }
            
            return "\(self.code)"
        }

        var description: String
        {
            if self.isSuccess
            {
                return "success data: \(data), json: \(json)"
            }
            else
            {
                if (self.code == 0)
                {
                    return "error: \(message)"
                }

                return "error: \(message) \(self.codeDescription)"
            }
        }
        
        init()
        {
            self.isSuccess = true
            self.code = 0
            self.message = ""
            self.data = nil
            self.json = nil
        }

        init(data: Data)
        {
            self.isSuccess = true
            self.code = 0
            self.message = ""
            self.data = data
            self.json = nil
        }

        init(json: [String: String])
        {
            self.isSuccess = true
            self.code = 0
            self.message = ""
            self.data = nil
            self.json = json
        }

        init(message: String)
        {
            self.isSuccess = false
            self.code = 0
            self.message = message
            self.data = nil
            self.json = nil
            
            print("[PZKeychain] error: \(message)")
        }

        init(code: OSStatus, message: String)
        {
            self.isSuccess = false
            self.code = code
            self.message = message
            self.data = nil
            self.json = nil

            print("[PZKeychain] error: \(message) (\(self.codeDescription))")
        }
    }

    let bundleIdentifier: String
    
    init(bundleIdentifier: String)
    {
        self.bundleIdentifier = bundleIdentifier
    }
    
    @discardableResult
    func set(json: [String: String], account: String) -> Result
    {
        if let data: Data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions(rawValue: 0))
        {
            return self.set(data: data, account: account)
        }
        else
        {
            return Result(message: "set [\(account)] json to data conversion")
        }
    }
    
    @discardableResult
    func set(string: String, account: String) -> Result
    {
        if let data = string.data(using: String.Encoding.utf8)
        {
            return self.set(data: data, account: account)
        }
        else
        {
            return Result(message: "set [\(account)] string utf8 conversion")
        }
    }

    @discardableResult
    func set(data: Data, account: String) -> Result
    {
        self.remove(account: account)

        let query: Query = Query(itemClass: .genericPassword, account: account, service: self.bundleIdentifier, synchronizable: false)
            
        query.attributeAccessible = Query.Accessible.always
        query.valueData = data

        let resultCode: OSStatus = SecItemAdd(query.dictionary, nil)
        
        if resultCode == errSecSuccess
        {
            return Result()
        }
        else
        {
            return Result(code: resultCode, message: "set [\(account)]")
        }
    }
    
    @discardableResult
    func remove(account: String) -> Result
    {
        let query: Query = Query(itemClass: .genericPassword, account: account, service: self.bundleIdentifier, synchronizable: false)
        
        query.attributeAccessible = Query.Accessible.always

        let resultCode: OSStatus = SecItemDelete(query.dictionary)
        
        if resultCode == errSecSuccess
        {
            return Result()
        }
        else
        {
            return Result(code: resultCode, message: "remove [\(account)]")
        }
    }
    
    func getData(account: String) -> Result
    {
        let query: Query = Query(itemClass: .genericPassword, account: account, service: self.bundleIdentifier, synchronizable: false)
        
        query.returnData = true
        query.searchMatchLimit = .limitOne

        var result: AnyObject?
        
        let resultCode: OSStatus = withUnsafeMutablePointer(to: &result)
        {
            SecItemCopyMatching(query.dictionary, UnsafeMutablePointer($0))
        }
        
        if resultCode == errSecSuccess
        {
            if let data = result as? Data
            {
                return Result(data: data)
            }
            else
            {
                return Result(message: "get data [\(account)] result type is not Data")
            }
        }
        else
        {
            return Result(code: resultCode, message: "get data [\(account)]")
        }
    }
    
    func getJson(account: String) -> Result
    {
        if let data = self.getData(account: account).data
        {
            if let object: Any = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            {
                if let json = object as? [String: String]
                {
                    return Result(json: json)
                }
                else
                {
                    return Result(message: "get json [\(account)] result type is not Dictionary")
                }
            }
            else
            {
                return Result(message: "get json [\(account)] data to json conversion")
            }
        }
        else
        {
            return Result(message: "get json [\(account)] data is nil")
        }
    }

}
