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
    let meteor: MeteorService
    let subscription: MeteorSubscription
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let username: PropertyOf<String>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        subscription = meteor.subscribe("me")
        avatar = meteor.user |> flatMap { $0.pAvatar() }
        displayName = meteor.user |> flatMap(nilValue: "") { $0.pDisplayName() }
        username = meteor.user |> flatMap(nilValue: "") { $0.pUsername() }
    }
    
    public func profileVM() -> ProfileViewModel? {
        return meteor.user.value.map { ProfileViewModel(meteor: meteor, user: $0) }
    }
    
    public func editProfileVM() -> EditProfileViewModel? {
        return meteor.user.value.map { EditProfileViewModel(meteor: meteor, user: $0) }
    }
}