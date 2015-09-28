//
//  Transition.swift
//  Taylr
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa

public class ViewControllerTransition : NSObject {
    public let fromVC : UIViewController
    public let toVC : UIViewController
    public var context : UIViewControllerContextTransitioning!
    public var cancelled : Bool { return context.transitionWasCancelled() }
    public var duration : NSTimeInterval = 0.6
    public var interactor : UIViewControllerInteractiveTransitioning?
    
    public var containerView : UIView {
        return context.containerView()!
    }
    public var fromView : UIView? {
        return context.viewForKey(UITransitionContextFromViewKey)
    }
    public var toView : UIView? {
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
    public func setup() {
    }

    public func animate() -> RACSignal {
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
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        context = transitionContext
        return duration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        animate().subscribeCompleted {
            self.completeTransition()
        }
    }
}
