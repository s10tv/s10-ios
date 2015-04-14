//
//  Transition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit


class ViewControllerTransition : NSObject {
    let fromVC : UIViewController
    let toVC : UIViewController
    let duration : NSTimeInterval
    var context : UIViewControllerContextTransitioning!
    var interactor : UIPercentDrivenInteractiveTransition?
    var cancelled : Bool { return context.transitionWasCancelled() }
    
    var containerView : UIView {
        return context.containerView()
    }
    var fromView : UIView? {
        return context.viewForKey(UITransitionContextFromViewKey)
    }
    var toView : UIView? {
        return context.viewForKey(UITransitionContextToViewKey)
    }
    
    init(fromVC: UIViewController, toVC: UIViewController, duration: NSTimeInterval = 0.6) {
        self.fromVC = fromVC
        self.toVC = toVC
        self.duration = duration
    }
    
    // To be overwritten by subclass
    func animate() {
    }
    
    func completeTransition() {
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
        animate()
    }
}
