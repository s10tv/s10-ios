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

@objc(RootViewController)
class RootViewController : UIViewController {
    
    @IBOutlet weak var loadingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as KetchBackgroundView
        
        view.whenSwiped(.Down) {
            view.animateHorizon(offset: 100, fromTop: false); return
        }
        view.whenSwiped(.Up) {
            view.animateHorizon(offset: 60); return
        }
        
        
        
        // If server logs us out, then let's also log out of the UI
        listenForNotification(METDDPClientDidChangeAccountNotification).filter { _ in
            return !Core.meteor.hasAccount()
        }.deliverOnMainThread().flattenMap { [weak self] _ in
//            if self?.topViewController is SignupViewController {
//                return RACSignal.empty()
//            }
            return UIAlertView.show("Error", message: "You have been logged out")
        }.subscribeNext { [weak self] _ in
            self?.showSignup(false)
            return
        }

        // Try login now
        if !Core.attemptLoginWithCachedCredentials() {
            loadingLabel.hidden = true
            showSignup(false)
        } else {
            Core.currentUserSubscription.signal.deliverOnMainThread().subscribeCompleted {
                self.loadingLabel.hidden = true
                self.showGame(false)
            }
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showProfile(user: User?, animated: Bool) {
//        setViewControllers([makeViewController(.Profile)!], animated: animated)
    }
    
    func showGame(animated: Bool) {
//        setViewControllers([makeViewController(.Game)!], animated: animated)
    }
    
    func showSignup(animated: Bool) {
//        setViewControllers([makeViewController(.Signup)!], animated: animated)
    }
    
    @IBAction func logout(sender: AnyObject) {
        showSignup(true)
        Core.logout().subscribeCompleted {
            Log.info("Signed out")
        }
    }
}
