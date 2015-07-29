//
//  UserDefaults.swift
//  Taylr
//
//  Created by Tony Xiao on 3/31/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// TODO: Replce with mutableProperty

// NOTE: Use Hungarian notation (http://en.wikipedia.org/wiki/Hungarian_notation)
// to name UserDefaultKey's because they are not statically typed
public enum UserDefaultKey : String {
    case sMeteorUserId = "meteorUserId"
    case sUserDisplayName = "userDisplayName"
    case sUserEmail = "userEmail"
    case iLastTabIndex = "lastTabIndex"
    
    public func defaultValue() -> Any? {
        switch self {
        default: return nil
        }
    }
    public static let allKeys = [sMeteorUserId]
}

extension NSUserDefaults {
    public subscript(key: UserDefaultKey) -> Proxy {
        return self[key.rawValue]
    }
    
    public subscript(key: UserDefaultKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
    
    public func registerDefaultValues() {
        for key in UserDefaultKey.allKeys {
            if let value = key.defaultValue() {
                Defaults[key] ?= value
            }
        }
    }
    
    public func resetAll() {
        removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        registerDefaultValues()
    }
}