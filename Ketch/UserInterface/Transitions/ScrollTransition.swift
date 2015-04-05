//
//  ScrollTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ScrollTransition : BaseTransition {
    enum Direction {
        case RightToLeft, LeftToRight
    }
    let direction : Direction
    init(rootVC: RootViewController, fromVC: UIViewController, toVC: UIViewController, direction: Direction) {
        self.direction = direction
        super.init(rootVC: rootVC, fromVC: fromVC, toVC: toVC, duration: 0.15)
    }
    
    override func animate() {
        var leftFrame = containerView.bounds
        leftFrame.origin.x -= leftFrame.width
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
                self.toView?.frame = self.containerView.bounds
            }) { completed in
                self.context.completeTransition(true)
        }
    }
}