//
//  PZSynchronized.swift
//  SynoTool
//
//  Created by Piotr on 07/12/2016.
//  Copyright © 2016 Piotr Zagawa. All rights reserved.
//

import Foundation

public func synchronized<T>(_ lock: AnyObject, closure: () -> T) -> T
{
    defer
    {
        objc_sync_exit(lock)
    }

    var result: T? = nil

    objc_sync_enter(lock)
    
    result = closure()
    
    return result!
}
