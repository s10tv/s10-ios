//
//  Transition.swift
//  Taylr
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewControllerTransition : NSObject {
    let fromVC : UIViewController
    let toVC : UIViewController
    var context : UIViewControllerContextTransitioning!
    var cancelled : Bool { return context.transitionWasCancelled() }
    var duration : NSTimeInterval = 0.6
    var interactor : UIViewControllerInteractiveTransitioning?
    
    var containerView : UIView {
        return context.containerView()
    }
    var fromView : UIView? {
        return context.viewForKey(UITransitionContextFromViewKey)
    }
    var toView : UIView? {
        return context.viewForKey(UITransitionContextToViewKey)
    }
    
    init(fromVC: UIViewController, toVC: UIViewController, interactor: UIViewControllerInteractiveTransitioning? = nil) {
        self.fromVC = fromVC
        self.toVC = toVC
        self.interactor = interactor
        super.init()
        setup()
    }
    
    // To be overwritten by subclass
    func setup() {
    }

    func animate() -> RACSignal {
        return RACSignal.empty()
    }
    
    // Helper, doesn't need to be called by subclass
    func completeTransition() {
        if cancelled {
            toView?.removeFromSuperview()
        }
        context.completeTransition(!cancelled)
    }
}

extension ViewControllerTransition : UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        context = transitionContext
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        animate().subscribeCompleted {
            self.completeTransition()
        }
    }
}
