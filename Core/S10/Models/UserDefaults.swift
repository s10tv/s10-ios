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
    public let accountState = ud.dyn("accountState").optional(String)
    public let lastTabIndex = ud.dyn("lastTabIndex").optional(Int)
    public let hideScrollDownHint = ud.dyn("hideScrollDownHint").optional(Bool)
    public let meteorUserId = ud.dyn("meteorUserId").optional(String)
    public let userDisplayName = ud.dyn("userDisplayName").optional(String)
    public let userEmail = ud.dyn("userEmail").optional(String)
    public let showPlayerTutorial = ud.dyn("showPlayerTutorial").optional(Bool)
    public let showSwipeFilterHint = ud.dyn("showSwipeFilterHint").optional(Bool)
    
    public func resetAll() {
        if let id = NSBundle.mainBundle().bundleIdentifier {
            ud.removePersistentDomainForName(id)
        }
    }
}

public let UD = UserDefaults()
