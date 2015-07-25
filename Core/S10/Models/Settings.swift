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
    
    public let softMinBuild: PropertyOf<Int?>
    public let hardMinBuild: PropertyOf<Int?>
    public let accountStatus: PropertyOf<AccountStatus?>
    
    public init(meteor: METDDPClient) {
        c = MeteorCollection(meteor.database.collectionWithName("settings"))
        softMinBuild = c.propertyOf("softMinBuild") |> map { $0.typed(Int) }
        hardMinBuild = c.propertyOf("hardMinBuild") |> map { $0.typed(Int) }
        accountStatus = c.propertyOf("accountStatus")
            |> map { $0.typed(String).flatMap { AccountStatus(rawValue: $0) }
        }
        meteor.addSubscriptionWithName("settings")
    }
}
