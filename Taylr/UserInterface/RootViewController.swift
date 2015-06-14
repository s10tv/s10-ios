//
//  RootViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Meteor
import FacebookSDK
import ReactiveCocoa
import EDColor

class RootViewController : UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.window?.tintColor = UIColor(hex: 0x9E7EA9)
        UITabBar.appearance().tintColor = UIColor(hex: 0x9E7EA9)
        
        if Meteor.account == nil {
            let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
            let signup = onboarding.instantiateInitialViewController() as! SignupViewController
            pushViewController(signup, animated: false)
        }
    }
}
