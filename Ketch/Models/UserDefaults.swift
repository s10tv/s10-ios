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
    case bGameTutorialMode = "bGameTutorialMode"
    case bHasBeenWelcomed = "bHasBeenWelcomed"
    
    func defaultValue() -> Any? {
        switch self {
            case .bGameTutorialMode: return true
            case .bHasBeenWelcomed: return false
            default: return nil
        }
    }
    static let allKeys = [bGameTutorialMode]
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
