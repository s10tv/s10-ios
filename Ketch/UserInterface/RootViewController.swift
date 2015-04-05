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
    var signupVC : UINavigationController!
    let gameVC = GameViewController()
    let dockVC = DockViewController()
    
    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    var rootView : RootView!
    
    override func loadView() {
        super.loadView()
        rootView = UIView.fromNib("RootView") as RootView
        view.insertSubview(rootView, atIndex: 0)
        rootView.makeEdgesEqualTo(view)
        view.backgroundColor = UIColor(hex: "F0FAF7")
    }
    
    
    
    // TODO: Refactor me into the right place
    let leftEdgePan = UIScreenEdgePanGestureRecognizer()
    let rightEdgePan = UIScreenEdgePanGestureRecognizer()
    
    var currentEdgePan : UIScreenEdgePanGestureRecognizer?
    func handleEdgePan(edgePan: UIScreenEdgePanGestureRecognizer) {
        switch edgePan.state {
        case .Began:
            currentEdgePan = edgePan
            if edgePan == rightEdgePan {
                pushViewController(DockViewController(), animated: true)
            } else if edgePan == leftEdgePan {
                popViewControllerAnimated(true)
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
        
        leftEdgePan.edges = .Left
        leftEdgePan.addTarget(self, action: "handleEdgePan:")
        rightEdgePan.edges = .Right
        rightEdgePan.addTarget(self, action: "handleEdgePan:")
        view.addGestureRecognizer(leftEdgePan)
        view.addGestureRecognizer(rightEdgePan)
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        let view = self.view as RootView
//        view.springDamping = 0.8
//        view.animateHorizon(offset: 60)
//        view.springDamping = 0.6
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
    
    // MARK: - Temporary
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        if !(pendingViewControllers[0] is GameViewController) {
            rootView.setKetchBoatHidden(true)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
//        if currentViewController is GameViewController {
//            rootView.setKetchBoatHidden(false)
//        }
    }
}

extension RootViewController : UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let loadingVC = fromVC as? LoadingViewController {
            if let gameVC = toVC as? GameViewController {
                return NewGameTransition(rootVC: self, loadingVC: loadingVC, gameVC: gameVC)
            }
        }
        if let gameVC = fromVC as? GameViewController {
            if let dockVC = toVC as? DockViewController {
                return ScrollTransition(fromVC: gameVC, toVC: dockVC, direction: .RightToLeft, panGesture: currentEdgePan)
            }
        }
        if let dockVC = fromVC as? DockViewController {
            if let gameVC = toVC as? GameViewController {
                return ScrollTransition(fromVC: gameVC, toVC: dockVC, direction: .LeftToRight, panGesture: currentEdgePan)
            }
        }
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? ViewControllerTransition)?.interactor
    }
}
