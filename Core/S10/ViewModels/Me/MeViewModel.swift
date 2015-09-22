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
import Bond

// TODO: Class vs struct
public class MeViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    public let subscription: MeteorSubscription
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let username: PropertyOf<String>
    public let profileIcons: DynamicArray<Image>
    public var disposable: Disposable!
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        subscription = meteor.subscribe("me")
        avatar = meteor.user |> flatMap { $0.pAvatar() }
        displayName = meteor.user |> flatMap(nilValue: "") { $0.pDisplayName() }
        username = meteor.user |> flatMap(nilValue: "") { $0.pUsername() }
        profileIcons = DynamicArray([])
        disposable = meteor.user.producer.start(next: { [weak self] user in
            if let user = user {
                self?.profileIcons.setArray(user.connectedProfiles.map { $0.icon })
            } else {
                self?.profileIcons.setArray([])
            }
        })
    }
    
    deinit {
        disposable.dispose()
    }
    
    public func canViewOrEditProfile() -> Bool {
        return meteor.user.value != nil
    }
    
    public func profileVM() -> ProfileViewModel? {
        return meteor.user.value.map { ProfileViewModel(meteor: meteor, taskService: taskService, user: $0) }
    }
    
    public func editProfileVM() -> EditProfileViewModel? {
        return meteor.user.value.map { EditProfileViewModel(meteor: meteor, user: $0) }
    }
}