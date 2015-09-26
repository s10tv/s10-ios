//
//  Settings.swift
//  Taylr
//
//  Created by Tony Xiao on 4/19/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

public class Settings {
    public enum AccountStatus : String {
        case Pending = "pending"
        case Active = "active"
    }
    let c: MeteorCollection
    let subscription: MeteorSubscription
    
    public let softMinBuild: PropertyOf<Int?>
    public let hardMinBuild: PropertyOf<Int?>
    public let upgradeURL: PropertyOf<NSURL?>
    public let debugLoginMode: PropertyOf<Bool?>
    public let accountStatus: PropertyOf<AccountStatus?>
    public let disableConfirmation: PropertyOf<Bool?>
    public let nextMatchDate: PropertyOf<NSDate?>
    public let matchInterval: PropertyOf<Int?>
    
    init(collection: MeteorCollection, subscription: MeteorSubscription) {
        self.c = collection
        self.subscription = subscription
        softMinBuild = c.propertyOf("softMinBuild").map { $0.typed(Int) }
        hardMinBuild = c.propertyOf("hardMinBuild").map { $0.typed(Int) }
        upgradeURL = c.propertyOf("upgradeUrl").map { $0.typed(String).flatMap { NSURL($0) } }
        debugLoginMode = c.propertyOf("debugLoginMode").map { $0.typed(Bool) }
        accountStatus = c.propertyOf("accountStatus")
            .map { $0.typed(String).flatMap { AccountStatus(rawValue: $0) }
        }
        disableConfirmation = c.propertyOf("disableConfirmation").map { $0.typed(Bool) }
        nextMatchDate = c.propertyOf("nextMatchDate").map { $0.typed(NSDate) }
        matchInterval = c.propertyOf("matchInterval").map { $0.typed(Int) }
    }
}
