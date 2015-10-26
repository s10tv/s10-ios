//
//  CurrentUser.swift
//  Taylr
//
//  Created by Tony Xiao on 4/19/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor

public class CurrentUser {
    public enum AccountStatus : String {
        case Pending = "pending"
        case Active = "active"
    }
    private let settingsCollection: MeteorCollection
    private let settingsSubscription: MeteorSubscription
    
    // Settings
    public let softMinBuild: PropertyOf<Int?>
    public let hardMinBuild: PropertyOf<Int?>
    public let upgradeURL: PropertyOf<NSURL?>
    public let debugLoginMode: PropertyOf<Bool?>
    public let accountStatus: PropertyOf<AccountStatus?>
    public let networkRequired: PropertyOf<Bool?>
    public let nextMatchDate: PropertyOf<NSDate?>
    public let matchInterval: PropertyOf<Int?>
    
    // CurrentUser
    let _userId: MutableProperty<String?>
    public let userId: PropertyOf<String?>
    public let firstName: PropertyOf<String?>
    public let lastName: PropertyOf<String?>
    public let gradYear: PropertyOf<String?>
    
    init(meteor: MeteorService) {
        self.settingsCollection = meteor.collection("settings")
        self.settingsSubscription = meteor.subscribe("settings")
        
        let s = settingsCollection
        softMinBuild = s.propertyOf("softMinBuild").map { $0.typed(Int) }
        hardMinBuild = s.propertyOf("hardMinBuild").map { $0.typed(Int) }
        upgradeURL = s.propertyOf("upgradeUrl").map { $0.typed(String).flatMap { NSURL($0) } }
        debugLoginMode = s.propertyOf("debugLoginMode").map { $0.typed(Bool) }
        accountStatus = s.propertyOf("accountStatus")
            .map { $0.typed(String).flatMap { AccountStatus(rawValue: $0) }
        }
        let kNetworkRequired = Environment.isRunningTestFlightBeta() ? "networkRequired" : "tfNetworkRequired"
        networkRequired = s.propertyOf(kNetworkRequired).map { $0.typed(Bool) }
        nextMatchDate = s.propertyOf("nextMatchDate").map { $0.typed(NSDate) }
        matchInterval = s.propertyOf("matchInterval").map { $0.typed(Int) }
        
        _userId = MutableProperty(UD.meteorUserId.value)
        userId = PropertyOf(_userId)
        let u = meteor.user
        firstName = u.flatMap { $0.pFirstName().map { Optional($0) } }
        lastName = u.flatMap { $0.pLastName().map { Optional($0) } }
        gradYear = u.flatMap { $0.pGradYear().map { Optional($0) } }
        
        // Quite a hack
        meteor.user.producer.skip(1).startWithNext { [weak self] u in
            UD.meteorUserId.value = u?.documentID
            if self?._userId.value != u?.documentID {
                self?._userId.value = u?.documentID
            }
        }
    }
}
