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
class RootViewController : PageViewController {
    
    let settingsVC = SettingsViewController()
    let gameVC = GameViewController()
    let dockVC = DockViewController()
    let chatVC = ChatViewController()
    
    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [gameVC, dockVC]
        let view = self.view as RootView
        view.loadingView.hidden = true
        
        loadFirstPage(animated: false)
        
        
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
            view.loadingView.hidden = true
            showSignup(false)
        } else {
//            Core.currentUserSubscription.signal.deliverOnMainThread().subscribeCompleted {

//                self.showGame(false)
//            }
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let view = self.view as RootView
        view.springDamping = 0.8
        view.animateHorizon(offset: 60)
        view.springDamping = 0.6
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        presentViewController(settingsVC, animated: true)
    }
    
    func showProfile(user: User?, animated: Bool) {
//        setViewControllers([makeViewController(.Profile)!], animated: animated)
    }
    
    func showGame(animated: Bool) {
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
