//
//  RootViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

class RootViewController : UINavigationController {
    
    func showProfile(user: User?, animated: Bool) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Profile") as UIViewController!
        setViewControllers([vc], animated: animated)
    }
    
    func showSignup(animated: Bool) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Signup") as UIViewController!
        setViewControllers([vc], animated: animated)
    }
    
}
