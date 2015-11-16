//
//  ActivityViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/28/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper

func viewModelForActivity(activity: AnyObject) -> ActivityViewModel {
//    return nil // TODO: Invalid server data causes a crash, what to do?
    if let activity = activity as? Activity, let type = activity.type {
        switch type {
        case .Image:
            return ActivityImageViewModel(activity: activity)
        case .Text:
            return ActivityTextViewModel(activity: activity)
        case .Link:
            fatalError("Not supported")
        case .Video:
            fatalError("Not supported")
        }
    }
    fatalError("Not supported")
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
        integrationName = profile?.integrationName ?? ""
        integrationColor = profile?.themeColor ?? UIColor.whiteColor()
        image = activity.image
        text = activity.text
    }
}

public struct ActivityTextViewModel : ActivityViewModel {
    public let avatar: Image?
    public let displayName: String
    public let displayTime: PropertyOf<String>
    public let integrationName: String
    public let integrationColor: UIColor
    
    public let text: String
    public let caption: String?
    
    init(activity: Activity) {
        let profile = activity.profile()
        avatar = profile?.avatar
        displayName = profile?.displayName ?? ""
        displayTime = relativeTime(activity.timestamp)
        integrationName = profile?.integrationName ?? ""
        integrationColor = profile?.themeColor ?? UIColor.blackColor()
        text = activity.text!
        caption = activity.caption
    }
}

public struct ActivityLinkViewModel {
}
