//
//  LoadingViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class LoadingViewController : BaseViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        waterlineLocation = .Bottom(60)
        hideKetchBoat = false
        if !Core.attemptLoginWithCachedCredentials() {
            performSegue(.Signup_)
        } else {
            performSegue(.LoadingToGame)
        }
    }
}