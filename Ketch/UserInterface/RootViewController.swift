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
class RootViewController : UIViewController,
                           UIPageViewControllerDelegate,
                           UIPageViewControllerDataSource {
    
    let settingsVC = SettingsViewController()
    let gameVC = GameViewController()
    let dockVC = DockViewController()
    let chatVC = ChatViewController()
    
    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    
    let scrollView = UIScrollView()
    let pageVC = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    var viewControllers : [UIViewController]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [gameVC, dockVC]
        let view = self.view as RootView
        view.loadingView.hidden = true
//        view.addSubview(scrollView)
//        scrollView.makeEdgesEqualTo(view)
        pageVC.delegate = self
        pageVC.dataSource = self
        
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.makeEdgesEqualTo(view)
        pageVC.didMoveToParentViewController(self)
        pageVC.setViewControllers([gameVC], direction: .Forward, animated: false) { finished in
            
        }
        
        
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
        addChildViewController(gameVC)
        view.addSubview(gameVC.view)
        gameVC.view.makeEdgesEqualTo(view)
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
    
    // MARK: Page View Controller Delegate / DataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let index = find(viewControllers, viewController) {
            return viewControllers.elementAtIndex(index - 1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let index = find(viewControllers, viewController) {
            return viewControllers.elementAtIndex(index + 1)
        }
        return nil
    }
}
