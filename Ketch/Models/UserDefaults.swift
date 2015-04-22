//
//  UserDefaults.swift
//  Ketch
//
//  Created by Tony Xiao on 3/31/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// NOTE: Use Hungarian notation (http://en.wikipedia.org/wiki/Hungarian_notation)
// to name UserDefaultKey's because they are not statically typed
enum UserDefaultKey : String {
    case sMeteorUserId = "meteorUserId"
    
    func defaultValue() -> Any? {
        switch self {
        default: return nil
        }
    }
    static let allKeys = [sMeteorUserId]
}

extension NSUserDefaults {
    subscript(key: UserDefaultKey) -> Proxy {
        return self[key.rawValue]
    }
    
    subscript(key: UserDefaultKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
    
    func registerDefaultValues() {
        for key in UserDefaultKey.allKeys {
            if let value = key.defaultValue() {
                Defaults[key] ?= value
            }
        }
    }
    
    func resetAll() {
        removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        registerDefaultValues()
    }
}