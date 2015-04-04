//
//  PermissionType.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

enum PermissionType {
    case Facebook, Notifications, Location
    
    private var imageName : String {
        switch self {
            case .Facebook:      return R.ImagesAssets.permFacebook
            case .Notifications: return R.ImagesAssets.permNotifications
            case .Location:      return R.ImagesAssets.permLocation
        }
    }
    private var buttonTitleKey : String {
        switch self {
            case .Facebook:      return R.Strings.permFacebookButtonTitle
            case .Notifications: return R.Strings.permNotificationsButtonTitle
            case .Location:      return R.Strings.permLocationButtonTitle
        }
    }
    private var explanationKey : String {
        switch self {
            case .Facebook:      return R.Strings.permFacebookExplanation
            case .Notifications: return R.Strings.permNotificationsExplanation
            case .Location:      return R.Strings.permLocationExplanation
        }
    }
    var image : UIImage {
        return UIImage(named: imageName)!
    }
    var buttonTitle : String {
        return LS(buttonTitleKey)
    }
    var explanation : String {
        return LS(explanationKey)
    }
}