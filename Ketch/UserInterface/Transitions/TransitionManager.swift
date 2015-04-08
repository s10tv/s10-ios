//
//  TransitionManager.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class TransitionManager : NSObject, UINavigationControllerDelegate {
    private let rootView : RootView
    var currentEdgePan : UIScreenEdgePanGestureRecognizer?
    var disableAllTransitions = false
    
    init(rootView: RootView, navigationController: UINavigationController?) {
        self.rootView = rootView
        super.init()
        navigationController?.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? BaseViewController {
            rootView.ketchIcon.hidden = vc.hideKetchBoat
            // TODO: This doesn't seem to work, maybe we need transitioningCoordinator?
//            if !animated {
//                rootView.waterlineLocation = vc.waterlineLocation
//            }
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if disableAllTransitions {
            return InstantaneousTransition(rootView, fromVC: fromVC, toVC: toVC)
        }

        switch (fromVC, toVC) {
            
        case let (fromVC as LoadingViewController, toVC as SignupViewController):
            return SignupTransition(rootView, loadingVC: fromVC, signupVC: toVC)
            
        case let (fromVC as LoadingViewController, toVC as WaitlistViewController):
            return WaitlistTransition(rootView, loadingVC: fromVC, waitlistVC: toVC)
            
        case let (fromVC as LoadingViewController, toVC as GameViewController):
            return NewGameTransition(rootView, loadingVC: fromVC, gameVC: toVC, operation: operation)

        case let (fromVC as GameViewController, toVC as LoadingViewController):
            return NewGameTransition(rootView, loadingVC: toVC, gameVC: fromVC, operation: operation)

        case (_ as GameViewController, _ as DockViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .RightToLeft, panGesture: currentEdgePan)
            
        case (_ as DockViewController, _ as GameViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .LeftToRight, panGesture: currentEdgePan)
            
        default:
            return RootTransition(rootView, fromVC: fromVC, toVC: toVC)
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? ViewControllerTransition)?.interactor
    }
}

