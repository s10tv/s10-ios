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
    @IBOutlet var rootView : RootView!
    
    var signupVC : UINavigationController!
    let gameVC = GameViewController()
    let dockVC = DockViewController()
    
    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    
    var currentEdgePan : UIScreenEdgePanGestureRecognizer?
    
    override func loadView() {
        super.loadView()
        UIView.fromNib("RootView", owner: self)
        view.insertSubview(rootView, atIndex: 0)
        rootView.makeEdgesEqualTo(view)
    }
    
    func handleEdgePan(gesture: UIScreenEdgePanGestureRecognizer, edge: UIRectEdge) {
        switch gesture.state {
        case .Began:
            currentEdgePan = gesture
            switch edge {
            case UIRectEdge.Right:
                pushViewController(DockViewController(), animated: true)
            case UIRectEdge.Left:
                popViewControllerAnimated(true)
            default:
                break
            }
        case .Ended, .Cancelled:
            currentEdgePan = nil
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
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
    
    @IBAction func goBack(sender: AnyObject) {
        popViewControllerAnimated(true)
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        presentViewController(SettingsViewController(), animated: true)
    }
    
    @IBAction func showDock(sender: AnyObject) {
        dismissViewController(animated: false) // HACK ALERT: for transitioning from NewConnection. Gotta use segue
//        scrollTo(viewController: dockVC)
        viewControllers = [gameVC, dockVC]
    }
    
    @IBAction func showGame(sender: AnyObject) {
        rootView.setKetchBoatHidden(false)
//        scrollTo(viewController: gameVC)
        viewControllers = [gameVC, dockVC]
    }
    
    func showProfile(user: User, animated: Bool) {
        let profileVC = ProfileViewController()
        profileVC.user = user
        presentViewController(profileVC, animated: animated)
    }
    
    func showChat(connection: Connection, animated: Bool) {
        let chatVC = ChatViewController()
        chatVC.connection = connection
//        scrollTo(viewController: chatVC, animated: animated)
        viewControllers = [gameVC, dockVC, chatVC]
        Core.meteor.callMethod("connection/markAsRead", params: [connection.documentID!])
    }
    
    func showNewMatch(connection: Connection) {
        let newConnVC = NewConnectionViewController()
        newConnVC.connection = connection
        presentViewController(newConnVC, animated: true)
    }
    
    func showSignup(animated: Bool) {
        signupVC = UINavigationController()
        signupVC.navigationBarHidden = true
        let vc = UIStoryboard(name: "Signup", bundle: nil).makeInitialViewController()
        signupVC.pushViewController(vc, animated: false)
        rootView.setKetchBoatHidden(true)
        dismissViewController(animated: false)
        addChildViewController(signupVC)
        view.addSubview(signupVC.view)
        signupVC.view.makeEdgesEqualTo(view)
        signupVC.didMoveToParentViewController(self)
    }
    
    @IBAction func finishSignup(sender: AnyObject) {
        signupVC.willMoveToParentViewController(nil)
        signupVC.view.removeFromSuperview()
        signupVC.removeFromParentViewController()
//        pageVC.view.hidden = false
        showGame(self)
    }
    
    @IBAction func logout(sender: AnyObject) {
//        pageVC.view.hidden = true // TODO: Refactor me
        showSignup(true)
        Core.logout().subscribeCompleted {
            Log.info("Signed out")
        }
    }
}

// MARK: - Navigation Transitions

extension RootViewController : UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch (fromVC, toVC) {
        case let (fromVC as LoadingViewController, toVC as GameViewController):
            return NewGameTransition(rootVC: self, loadingVC: fromVC, gameVC: toVC)
        case (_ as GameViewController, _ as DockViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .RightToLeft, panGesture: currentEdgePan)
        case (_ as DockViewController, _ as GameViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .LeftToRight, panGesture: currentEdgePan)
        default:
            return nil
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? ViewControllerTransition)?.interactor
    }
}
