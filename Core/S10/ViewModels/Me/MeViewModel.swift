//
//  MeViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

public struct MeViewModel {
    let subscription: MeteorSubscription
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let username: PropertyOf<String>
    
    public init(meteor: MeteorService) {
        let user = meteor.user.value!
        subscription = meteor.subscribe("me")
        avatar = user.pAvatar()
        displayName = user.pDisplayName()
        username = user.pUsername()
    }
}