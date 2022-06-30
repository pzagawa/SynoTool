//
//  PZAuthData.swift
//  SynoTool
//
//  Created by Piotr on 17/12/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

struct PZAuthData
{
    var host: String
    var account: String
    var password: String
    
    var urlHost: NSURL?
    {
        return NSURL(string: host)
    }
    
    init(host: String, account: String, password: String)
    {
        self.host = host
        self.account = account
        self.password = password
    }
    
    init?(json: [String: String])
    {
        guard let host = json["host"] else
        {
            return nil
        }
        
        guard let account = json["account"] else
        {
            return nil
        }
        
        guard let password = json["password"] else
        {
            return nil
        }
        
        self.host = host
        self.account = account
        self.password = password
    }
    
    var json: [String: String]
    {
        return [
            "host": self.host,
            "account": self.account,
            "password": self.password,
        ]
    }
    
    var description: String
    {
        return "HOST: \(host). ACCOUNT: \(account)"
    }
}
