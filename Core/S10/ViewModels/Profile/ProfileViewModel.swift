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

private func supportedActivitiesByUser(user: User) -> NSPredicate {
    let supportedTypes: [Activity.ContentType] = [.Image, .Text]
    return NSPredicate(format: "%K == %@ && %K IN %@",
        ActivityKeys.user.rawValue, user,
        ActivityKeys.type_.rawValue, supportedTypes.map { $0.rawValue })
}

public struct ProfileViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let user: User
    let subscription: MeteorSubscription
    let currentFilter: MutableProperty<User.ConnectedProfile?>
    let frc: NSFetchedResultsController
    
    public let coverVM: DynamicArray<ProfileCoverViewModel>
    public let infoVM: DynamicArray<ProfileInfoViewModel>
    public let activities: DynamicArray<ActivityViewModel>
    
    init(meteor: MeteorService, taskService: TaskService, user: User) {
        self.meteor = meteor
        self.taskService = taskService
        self.user = user
        subscription = meteor.subscribe("activities", user)
        currentFilter = MutableProperty(nil)
        coverVM = DynamicArray([ProfileCoverViewModel(user: user)])
        infoVM = toBondDynamicArray(currentFilter |> map {
            $0.map { [ConnectedProfileInfoViewModel(profile: $0)] }
                ?? [TaylrProfileInfoViewModel(user: user)]
        })
        frc = Activity
            .by(supportedActivitiesByUser(user))
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .fetchedResultsController(nil)
        activities = frc.results(Activity)
            .map(viewModelForActivity)
    }
    
    public func selectProfile(profileId: String) {
        // TODO: Implement filtering profile by id
    }
    
    public func conversationVM() -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, taskService: taskService, recipient: user)
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
            user.pConnectedProfiles() |> map { $0.map { $0.icon } }
        )
        proximity = PropertyOf("", combineLatest(
            user.dyn(.distance).optional(Double).producer,
            user.dyn(.lastActive).optional(NSDate).producer,
            CurrentTime.producer
        ) |> map {
            let distance = $0.map { Formatters.formatDistance($0) + " away" } ?? ""
            let lastActive = Formatters.formatRelativeDate($1, relativeTo: $2) ?? ""
            return "\(distance), \(lastActive)"
        })
    }
}

