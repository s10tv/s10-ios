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
    public let imageURL: Dynamic<NSURL?>
    public let serviceIcon: Dynamic<UIImage?>
    public let formattedDate: Dynamic<String>
    public let formattedAction: Dynamic<String>

    
    public init(_ activity: Activity) {
        self.activity = activity
        imageURL = activity.imageURL
        serviceIcon = (activity.service?.type ?? Dynamic(nil)).map {
            if let type = $0 {
                switch type {
                // TODO: Figure out ways to avoid hardcoding image name
                case .Facebook: return UIImage(named: "ic-facebook")
                case .Instagram: return UIImage(named: "ic-instagram")
                }
            }
            return nil
        }
        formattedDate = reduce(activity.dynTimestamp, CurrentDate) {
            Formatters.formatRelativeDate($0, relativeTo: $1) ?? ""
        }
        formattedAction = activity.dynAction.map {
            if let action = $0 {
                switch action {
                case .Post: return "Posted"
                case .Like: return "Liked"
                }
            }
            return ""
        }
    }
}