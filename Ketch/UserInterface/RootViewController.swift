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

extension UIViewController {
    var rootVC : RootViewController {
        return UIApplication.sharedApplication().delegate?.window??.rootViewController as RootViewController
    }
}

@objc(RootViewController)
class RootViewController : PageViewController {
    let signupVC = SignupViewController()
    let gameVC = GameViewController()
    let dockVC = DockViewController()
    
    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [gameVC, dockVC]
        let view = self.view as RootView
        
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
            if self?.signupVC.parentViewController != nil {
                return RACSignal.empty()
            }
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
            Core.currentUserSubscription.signal.deliverOnMainThread().subscribeCompleted {
                view.loadingView.hidden = true
                self.scrollTo(viewController: self.gameVC, animated: false)
                return
            }
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
        presentViewController(SettingsViewController(), animated: true)
    }
    
    @IBAction func showDock(sender: AnyObject) {
        dismissViewController(animated: false) // HACK ALERT: for transitioning from NewConnection. Gotta use segue
        scrollTo(viewController: dockVC)
        viewControllers = [gameVC, dockVC]
    }
    
    @IBAction func showGame(sender: AnyObject) {
        scrollTo(viewController: gameVC)
        viewControllers = [gameVC, dockVC]
    }
    
    @IBAction func login(sender: AnyObject) {
        Core.loginWithUI().subscribeCompleted {
            self.signupVC.willMoveToParentViewController(nil)
            self.signupVC.view.removeFromSuperview()
            self.signupVC.removeFromParentViewController()
            self.showGame(self)
        }
    }
    
    func showProfile(user: User, animated: Bool) {
        let profileVC = ProfileViewController()
        profileVC.user = user
        presentViewController(profileVC, animated: animated)
    }
    
    func showChat(connection: Connection, animated: Bool) {
        let chatVC = ChatViewController()
        chatVC.connection = connection
        scrollTo(viewController: chatVC, animated: animated)
        viewControllers = [gameVC, dockVC, chatVC]
        Core.meteor.callMethod("connection/markAsRead", params: [connection.documentID!])
    }
    
    func showNewMatch(connection: Connection) {
        let newConnVC = NewConnectionViewController()
        newConnVC.connection = connection
        presentViewController(newConnVC, animated: true)
    }
    
    func showSignup(animated: Bool) {
        dismissViewController(animated: false)
        addChildViewController(signupVC)
        view.addSubview(signupVC.view)
        signupVC.view.makeEdgesEqualTo(view)
        signupVC.didMoveToParentViewController(self)
    }
    
    @IBAction func logout(sender: AnyObject) {
        showSignup(true)
        Core.logout().subscribeCompleted {
            Log.info("Signed out")
        }
    }
}
