//
//  ProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import Box

public struct ProfileViewModel {
    let meteor: MeteorService
    let user: User
    let subscription: MeteorSubscription
    let currentFilter: MutableProperty<User.ConnectedProfile?>
    let frc: NSFetchedResultsController
    
    public let coverVM: DynamicArray<ProfileCoverViewModel>
    public let infoVM: DynamicArray<ProfileInfoViewModel>
    public let activities: DynamicArray<ActivityViewModel>
    
    init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        subscription = meteor.subscribe("activities", user)
        currentFilter = MutableProperty(nil)
        coverVM = DynamicArray([ProfileCoverViewModel(user: user)])
        infoVM = toBondDynamicArray(currentFilter |> map {
            $0.map { [ConnectedProfileInfoViewModel(profile: $0)] }
                ?? [TaylrProfileInfoViewModel(user: user)]
        })
        frc = Activity
            .by(ActivityKeys.user, value: user)
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .fetchedResultsController(nil)
        activities = frc.results(Activity)
            .map(viewModelForActivity)
            .filter { $0 != nil }
            .map { vm, _ in vm! }
    }
    
    public func selectProfile(profileId: String) {
        // TODO: Implement filtering profile by id
    }
    
    public func conversationVM() -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, recipient: user)
    }
}

public struct ProfileCoverViewModel {
    public let firstName: PropertyOf<String>
    public let lastName: PropertyOf<String>
    public let proximity: PropertyOf<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let selectorImages: DynamicArray<Image>
    
    init(user: User) {
        firstName = user.pFirstName()
        lastName = user.pLastName()
        avatar = user.pAvatar()
        cover = user.pCover()
        selectorImages = toBondDynamicArray(
            user.pConnectedProfiles() |> map { $0.map { $0.avatar } }
        )
        proximity = PropertyOf("", combineLatest(
            user.dyn(.distance).optional(Double).producer,
            user.dyn(.lastActive).optional(NSDate).producer,
            timer(1, onScheduler: QueueScheduler.mainQueueScheduler)
        ) |> map {
            let distance = $0.map { Formatters.formatDistance($0) + " away" } ?? ""
            let lastActive = Formatters.formatRelativeDate($1, relativeTo: $2) ?? ""
            return "\(distance), \(lastActive)"
        })
    }
}

