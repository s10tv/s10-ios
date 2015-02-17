//
//  RootViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import FacebookSDK

class RootViewController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Core.attemptLoginWithCachedCredentials() {
            showSignup(false)
        } else {
            showDiscover(false)
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let vc = topViewController {
            return vc.prefersStatusBarHidden()
        } else {
            return false
        }
    }
        
    func showProfile(user: User?, animated: Bool) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Profile") as UIViewController!
        setViewControllers([vc], animated: animated)
    }
    
    func showDiscover(animated: Bool) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Discover") as UIViewController!
        setViewControllers([vc], animated: animated)
    }
    
    func showSignup(animated: Bool) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("Signup") as UIViewController!
        setViewControllers([vc], animated: animated)
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.showSignup(true)
        Core.logout().subscribeCompleted {
            Log.info("Signed out")
        }
    }
}
