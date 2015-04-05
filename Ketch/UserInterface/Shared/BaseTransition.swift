//
//  BaseTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class BaseTransition : NSObject {
    let rootVC : RootViewController
    let fromVC : UIViewController
    let toVC : UIViewController
    let duration : NSTimeInterval
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
    
    init(rootVC: RootViewController, fromVC: UIViewController, toVC: UIViewController, duration: NSTimeInterval = 0.6) {
        self.rootVC = rootVC
        self.fromVC = fromVC
        self.toVC = toVC
        self.duration = duration
    }
    
    // To be overwritten by subclass
    func animate() {
    }
}

extension BaseTransition : UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        context = transitionContext
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        animate()
    }
}
