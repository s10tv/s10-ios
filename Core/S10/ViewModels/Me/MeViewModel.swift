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
        subscription = meteor.subscribe("me")
        avatar = meteor.user
            |> flatMap { $0?.pAvatar() ?? PropertyOf(nil) }
        displayName = meteor.user
            |> flatMap { $0?.pDisplayName() ?? PropertyOf("") }
        username = meteor.user
            |> flatMap { $0?.pUsername() ?? PropertyOf("") }
    }
}