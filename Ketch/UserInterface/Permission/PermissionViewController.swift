//
//  PermissionViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@objc(PermissionViewController)
class PermissionViewController : BaseViewController {
    enum Type {
        case Facebook, Notifications, Location
        var imageName : String {
            switch self {
                case .Facebook:      return R.ImagesAssets.permFacebook
                case .Notifications: return R.ImagesAssets.permNotifications
                case .Location:      return R.ImagesAssets.permLocation
            }
        }
        var image : UIImage {
            return UIImage(named: imageName)!
        }
    }
    
    var permissionType : Type!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}