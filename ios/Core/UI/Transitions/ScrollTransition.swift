//
//  ScrollTransition.swift
//  Taylr
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class ScrollTransition : ViewControllerTransition {
    public enum Direction {
        case RightToLeft, LeftToRight
    }
    let direction : Direction
    
    public init(fromVC: UIViewController, toVC: UIViewController, direction: Direction, panGesture: UIPanGestureRecognizer?) {
        self.direction = direction
        super.init(fromVC: fromVC, toVC: toVC, interactor: panGesture.map { PanInteractor($0) })
        duration = 0.3
    }
    
    public override func animate() -> Future<Bool, NoError> {
        var leftFrame = containerView.bounds
        leftFrame.origin.x -= leftFrame.width
        let centerFrame = containerView.bounds
        var rightFrame = containerView.bounds
        rightFrame.origin.x += rightFrame.width
        
        self.containerView.addSubview(self.toView!)
        let toInitialFrame = direction == .RightToLeft ? rightFrame : leftFrame
        let fromFinalFrame = direction == .RightToLeft ? leftFrame : rightFrame
        toView?.frame = toInitialFrame
        
        return UIView.animate(duration, options: .CurveEaseInOut) {
            self.fromView?.frame = fromFinalFrame
            self.toView?.frame = centerFrame
        }.onComplete { _ in
            if (self.cancelled) {
                self.fromView?.frame = centerFrame
            }
        }
    }
}