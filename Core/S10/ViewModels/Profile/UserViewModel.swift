//
//  UserViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper
import Bond

public struct UserViewModel {
    let meteor: MeteorService
    let user: User
    public let username: PropertyOf<String>
    public let jobTitle: PropertyOf<String>
    public let employer: PropertyOf<String>
    public let about: PropertyOf<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let distance: PropertyOf<String>
    public let lastActive: PropertyOf<String>
    public let activities: DynamicArray<ActivityViewModel>
    public let profiles: DynamicArray<ConnectedProfile>
    
    init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        username = user.pUsername()
        displayName = user.pDisplayName()
        jobTitle = user.pJobTitle()
        employer = user.pEmployer()
        about = user.pAbout()
        avatar = user.pAvatar()
        cover = user.pCover()
        distance = user.dyn(.distance).optional(Double) |> map {
            $0.map { Formatters.formatDistance($0) + " away" } ?? ""
        }
        lastActive = PropertyOf("", combineLatest(
            user.dyn(.lastActive).optional(NSDate).producer,
            timer(1, onScheduler: QueueScheduler.mainQueueScheduler)
        ) |> map {
            Formatters.formatRelativeDate($0, relativeTo: $1) ?? ""
        })
//        subscription = meteor.subscribe("userActivities", params: [user.documentID!])
        activities = DynamicArray([])
//            Activity
//            .by(ActivityKeys.user, value: user)
//            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
//            .results(Activity).map { ActivityViewModel($0) }
        let array = DynamicArray<ConnectedProfile>([])
        user.dyn(.connectedProfiles_).producer
            |> map(Mapper<ConnectedProfile>().mapArray)
            |> start(next: { [weak array] mapped in
                array?.value = mapped ?? []
            })
        profiles = array
    }
    

}
