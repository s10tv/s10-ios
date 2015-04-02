//
//  NewMatchTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/2/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class NewMatchTransition : NSObject {
    var rootVC : RootViewController!
    var gameVC : GameViewController!
    var newMatchVC : NewConnectionViewController!
    var context : UIViewControllerContextTransitioning!
    
    var containerView : UIView {
        return context.containerView()
    }
    var fromView : UIView? {
        return context.viewForKey(UITransitionContextFromViewKey)
    }
    var toView : UIView? {
        return context.viewForKey(UITransitionContextToViewKey)
    }
}

extension NewMatchTransition : UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        rootVC = presenting as RootViewController
        gameVC = source as GameViewController
        newMatchVC = presented as NewConnectionViewController
        return self
    }
}

extension NewMatchTransition : UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        context = transitionContext
        return 0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext

        fromView?.removeFromSuperview()
        containerView.addSubview(toView!)
        toView?.frame = context.finalFrameForViewController(newMatchVC)
        context.completeTransition(true)
    }
}