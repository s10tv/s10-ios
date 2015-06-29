//
//  ActivityViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/28/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public class ActivityViewModel {
    let activity: Activity
    public let imageURL: Dynamic<NSURL?>
    public let serviceIcon: Dynamic<UIImage?>
    
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
    }
}