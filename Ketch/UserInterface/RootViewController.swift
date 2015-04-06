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
import Spring

extension UIViewController {
    var rootVC : RootViewController {
        return UIApplication.sharedApplication().delegate?.window??.rootViewController as RootViewController
    }
}

@objc(RootViewController)
class RootViewController : UINavigationController {
    private let rootView = UIView.fromNib("RootView") as RootView
    var transitionManager : TransitionManager!
    
    override func loadView() {
        super.loadView()
        view.insertSubview(rootView, atIndex: 0)
        rootView.makeEdgesEqualTo(view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionManager = TransitionManager(rootView: rootView, navigationController: self)
        
        view.whenEdgePanned(.Left, handler: handleEdgePan)
        view.whenEdgePanned(.Right, handler: handleEdgePan)
        
//        viewControllers = [gameVC, dockVC]
//        
//        // If server logs us out, then let's also log out of the UI
//        listenForNotification(METDDPClientDidChangeAccountNotification).filter { _ in
//            return !Core.meteor.hasAccount()
//        }.deliverOnMainThread().flattenMap { [weak self] _ in
//            if self?.signupVC?.parentViewController != nil {
//                return RACSignal.empty()
//            }
//            return UIAlertView.show("Error", message: "You have been logged out")
//        }.subscribeNext { [weak self] _ in
//            self?.showSignup(false)
//            return
//        }
//
//        // Try login now
//        if !Core.attemptLoginWithCachedCredentials() {
//            self.rootView.loadingView.hidden = true
//            showSignup(false)
//        } else {
//            Core.currentUserSubscription.signal.deliverOnMainThread().subscribeCompleted {
//                self.rootView.loadingView.hidden = true
//                if User.currentUser()?.vetted == "yes" {
////                    self.scrollTo(viewController: self.gameVC, animated: false)
//                } else {
//                    self.rootView.animateHorizon(ratio: 0.6)
//                    let vc = WaitlistViewController()
//                    self.addChildViewController(vc)
//                    self.view.addSubview(vc.view)
//                    vc.view.makeEdgesEqualTo(self.view)
//                    vc.didMoveToParentViewController(self)
//                }
//            }
//        }

    }
    
    // MARK: Target Action
    
    func handleEdgePan(gesture: UIScreenEdgePanGestureRecognizer, edge: UIRectEdge) {
        switch gesture.state {
        case .Began:
            transitionManager.currentEdgePan = gesture
            if let vc = self.topViewController as? BaseViewController {
                vc.handleScreenEdgePan(edge)
            }
        case .Ended, .Cancelled:
            transitionManager.currentEdgePan = nil
        default:
            break
        }
    }
    
    @IBAction func goBack(sender: AnyObject) {
        if let vc = presentedViewController {
            dismissViewController(animated: true)
        } else {
            popViewControllerAnimated(true)
        }
    }
    
    func showNewMatch(connection: Connection) {
        let newConnVC = NewConnectionViewController()
        newConnVC.connection = connection
        presentViewController(newConnVC, animated: true)
    }
    
    @IBAction func logout(sender: AnyObject) {
//        pageVC.view.hidden = true // TODO: Refactor me
        Core.logout().subscribeCompleted {
            Log.info("Signed out")
        }
        dismissViewController(animated: false)
        popToRootViewControllerAnimated(true)
    }
}
