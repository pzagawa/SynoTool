//
//  PZSynoError.swift
//  SynoTool
//
//  Created by Piotr on 10/10/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

class PZSynoError
{
    static let ERROR_CODE_LOGIN_NO_PERMISSION = 105
    static let ERROR_CODE_LOGIN_DUPLICATE = 107
    static let ERROR_CODE_SYSTEM_ERROR = 119
    
    private var isLoginNoPermission: Bool = false
    private var isLoginDuplicate: Bool = false
    private var isSystemError: Bool = false
    
    var isReauthenticationRequired: Bool
    {
        return (self.isLoginNoPermission || self.isLoginDuplicate || self.isSystemError)
    }
    
    func reset()
    {
        self.isLoginNoPermission = false
        self.isLoginDuplicate = false
        self.isSystemError = false
    }
    
    func checkErrorCode(errorCode: Int)
    {
        if (errorCode == PZSynoError.ERROR_CODE_LOGIN_NO_PERMISSION)
        {
            self.isLoginNoPermission = true
        }
        
        if (errorCode == PZSynoError.ERROR_CODE_LOGIN_DUPLICATE)
        {
            self.isLoginDuplicate = true
        }
        
        if (errorCode == PZSynoError.ERROR_CODE_SYSTEM_ERROR)
        {
            self.isSystemError = true
        }
    }
}
