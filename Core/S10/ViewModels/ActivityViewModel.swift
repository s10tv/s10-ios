//
//  ActivityViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/28/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public struct ActivityViewModel {
    let activity: Activity
    public let avatarURL: Dynamic<NSURL?>
    public let username: Dynamic<String>
    public let formattedDate: Dynamic<String>
    public let imageURL: Dynamic<NSURL?>
    public let text: Dynamic<String>
    public let quote: Dynamic<String>
    public let serviceName: Dynamic<String>
    
    public init(_ activity: Activity) {
        self.activity = activity
        let service = activity.service!
        avatarURL = service.userAvatarURL
        username = service.dynUserDisplayName.map { $0 ?? "" }
        formattedDate = reduce(activity.dynTimestamp, CurrentDate) {
            Formatters.formatRelativeDate($0, relativeTo: $1) ?? ""
        }
        imageURL = activity.imageURL
        text = activity.dynText.map { $0 ?? "" }
        quote = activity.dynQuote.map { $0 ?? "" }
        serviceName = service.type.map { $0?.rawValue ?? "" }
    }
}