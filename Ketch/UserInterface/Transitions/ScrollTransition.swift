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
    let panGesture : UIPanGestureRecognizer?
    let panSelector : Selector = "handlePanGesture:"
    
    init(rootVC: RootViewController, fromVC: UIViewController, toVC: UIViewController, direction: Direction, panGesture: UIPanGestureRecognizer?) {
        self.direction = direction
        self.panGesture = panGesture
        super.init(rootVC: rootVC, fromVC: fromVC, toVC: toVC, duration: 0.3)
        if let panGesture = panGesture {
            interactor = UIPercentDrivenInteractiveTransition()
            panGesture.addTarget(self, action: panSelector)
        }
    }
    
    deinit {
        panGesture?.removeTarget(self, action: panSelector)
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
    
    func handlePanGesture(pan: UIScreenEdgePanGestureRecognizer) {
        let point = pan.translationInView(containerView)
        let percent = abs(point.x / containerView.frame.width)
        switch pan.state {
        case .Changed:
            interactor?.updateInteractiveTransition(percent)
            println("Updating to \(percent)")
        case .Ended, .Cancelled:
            if percent > 0.25 && pan.state != .Cancelled {
                interactor?.finishInteractiveTransition()
            } else {
                interactor?.cancelInteractiveTransition()
            }
        default:
            break
        }
    }
}