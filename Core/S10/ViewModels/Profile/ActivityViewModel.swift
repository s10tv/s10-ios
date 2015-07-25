//
//  ActivityViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/28/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import ReactiveCocoa
import ObjectMapper

public protocol ActivityViewModel {
    var avatar: Image { get }
    var displayName: String { get }
    var displayTime: PropertyOf<String> { get }
    var integrationName: String { get }
    var integrationColor: UIColor  { get }
}

public struct ActivityImageViewModel : ActivityViewModel {
    public let avatar: Image
    public let displayName: String
    public let displayTime: PropertyOf<String>
    public let integrationName: String
    public let integrationColor: UIColor
    
    public let image: Image
    
    public init(activity: Activity, profile: UserViewModel.Profile) {
        avatar = profile.avatar
        displayName = profile.displayName
        displayTime = relativeTime(activity.timestamp)
        integrationName = profile.displayId! // Need integrationName
        integrationColor = UIColor.blackColor()
        image = Mapper<Image>().map(activity.image!)!
    }
}

public struct ActivityListViewModel {
    let activities: DynamicArray<ActivityViewModel>
    
    public init(user: User, profile: UserViewModel.Profile) {
        activities = Activity
            .by(ActivityKeys.user, value: user)
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .results(Activity)
            .filter { $0.type == "image" }
            .map { ActivityImageViewModel(activity: $0, profile: profile) }
    }
}
