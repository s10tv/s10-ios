//
//  ScrollTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ScrollTransition : ViewControllerTransition {
    enum Direction {
        case RightToLeft, LeftToRight
    }
    let direction : Direction
    
    init(fromVC: UIViewController, toVC: UIViewController, direction: Direction, panGesture: UIPanGestureRecognizer?) {
        self.direction = direction
        super.init(fromVC: fromVC, toVC: toVC, duration: 0.3, interactor: panGesture.map { PanInteractor($0) })
    }
    
    // TODO: What if we add animation to CALayer, will interactive animation break?
    override func animate() {
        var leftFrame = containerView.bounds
        leftFrame.origin.x -= leftFrame.width
        var centerFrame = containerView.bounds
        var rightFrame = containerView.bounds
        rightFrame.origin.x += rightFrame.width
        
        self.containerView.addSubview(self.toView!)
        var toInitialFrame = direction == .RightToLeft ? rightFrame : leftFrame
        var fromFinalFrame = direction == .RightToLeft ? leftFrame : rightFrame
        toView?.frame = toInitialFrame
        
        UIView.animateWithDuration(duration,
            delay: 0, options: .CurveEaseInOut,
            animations: {
                self.fromView?.frame = fromFinalFrame
                self.toView?.frame = centerFrame
            }) { completed in
                if (self.cancelled) {
                    self.toView?.removeFromSuperview()
                    self.fromView?.frame = centerFrame
                }
                self.completeTransition()
            }
    }
}