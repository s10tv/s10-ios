//
//  CurrentUser.swift
//  Taylr
//
//  Created by Tony Xiao on 4/19/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class CurrentUser {
    public enum AccountStatus : String {
        case Pending = "pending"
        case Active = "active"
    }
    
    // CurrentUser
    let _userId: MutableProperty<String?>
    public let userId: PropertyOf<String?>
    public let firstName: PropertyOf<String?>
    public let lastName: PropertyOf<String?>
    public let gradYear: PropertyOf<String?>
    
    public init() {
        _userId = MutableProperty(UD.meteorUserId.value)
        userId = PropertyOf(_userId)
        firstName = PropertyOf(nil)
        lastName = PropertyOf(nil)
        gradYear = PropertyOf(nil)
    }
}
