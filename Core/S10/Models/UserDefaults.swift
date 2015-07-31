//
//  UserDefaults.swift
//  Taylr
//
//  Created by Tony Xiao on 3/31/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa

private let ud = NSUserDefaults.standardUserDefaults()

public struct UserDefaults {
    public let lastTabIndex = ud.dyn("lastTabIndex").optional(Int)
    public let meteorUserId = ud.dyn("meteorUserId").optional(String)
    public let userDisplayName = ud.dyn("userDisplayName").optional(String)
    public let userEmail = ud.dyn("userEmail").optional(String)
    
    public func resetAll() {
        NSBundle.mainBundle().bundleIdentifier.map {
            ud.removePersistentDomainForName($0)
        }
    }
}

public let UD = UserDefaults()
