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

public struct ProfileViewModel {
    let subscription: MeteorSubscription
    let activities: DynamicArray<ActivityViewModel>
    
    init(meteor: MeteorService, user: User) {
        var profile: ConnectedProfile!
        subscription = meteor.subscribe("activities", params: [user])
        activities = Activity
            .by(ActivityKeys.user, value: user)
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .results(Activity)
            .filter { $0.type == .Image }
            .map { ActivityImageViewModel(activity: $0, profile: profile) }
    }
}

public struct ProfileSelectorViewModel {
    
}

