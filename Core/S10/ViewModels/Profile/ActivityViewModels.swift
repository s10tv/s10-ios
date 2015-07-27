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

func viewModelForActivity(activity: Activity) -> ActivityViewModel? {
//    return nil // TODO: Invalid server data causes a crash, what to do?
    if let type = activity.type {
        return ActivityImageViewModel(activity: activity)
        switch type {
        case .Image:
            return ActivityImageViewModel(activity: activity)
        case .Text:
            return nil
        case .Link:
            return nil
        case .Video:
            return nil
        }
    }
    return nil
}

public protocol ActivityViewModel {
    var avatar: Image? { get }
    var displayName: String { get }
    var displayTime: PropertyOf<String> { get }
    var integrationName: String { get }
    var integrationColor: UIColor  { get }
}

public struct ActivityImageViewModel : ActivityViewModel {
    public let avatar: Image? // TODO: Get a placeholder
    public let displayName: String
    public let displayTime: PropertyOf<String>
    public let integrationName: String
    public let integrationColor: UIColor
    
    public let image: Image
    public let text: String?
    
    init(activity: Activity) {
        let profile = activity.profile()
        avatar = profile?.avatar
        displayName = profile?.displayName ?? ""
        displayTime = relativeTime(activity.timestamp)
        integrationName = profile?.displayId ?? ""
        integrationColor = UIColor.whiteColor()
        image = activity.image
        text = activity.text
    }
}

public struct ActivityTextViewModel {
}

public struct ActivityLinkViewModel {
}
