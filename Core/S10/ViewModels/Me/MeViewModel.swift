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
    let ctx: Context
    let subscription: MeteorSubscription
    let subMyTags: MeteorSubscription
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let profileIcons: ArrayProperty<Image>
    public let hashtags: FetchedResultsArray<HashtagViewModel>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        let meteor = ctx.meteor
        subscription = meteor.subscribe("me")
        subMyTags = meteor.subscribe("my-hashtags")
        avatar = meteor.user.flatMap { $0.pAvatar() }
        cover = meteor.user.flatMap { $0.pCover() }
        displayName = meteor.user.flatMap(nilValue: "") { $0.pDisplayName() }
        profileIcons = meteor.user
            .flatMap(nilValue: []) { $0.pConnectedProfiles() }
            .map { $0.map { $0.icon } }
            .array()
        hashtags = Hashtag
            .by(HashtagKeys.selected, value: true)
            .results { HashtagViewModel(hashtag: $0 as! Hashtag) }
    }
    
    public func canViewOrEditProfile() -> Bool {
        return ctx.meteor.user.value != nil
    }
    
    public func profileVM() -> ProfileViewModel? {
        return ctx.meteor.user.value.map { ProfileViewModel(ctx, user: $0) }
    }
    
    public func editProfileVM() -> EditProfileViewModel? {
        return ctx.meteor.user.value.map { EditProfileViewModel(ctx, user: $0) }
    }
}