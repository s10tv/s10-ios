//
//  PanInteractor.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class PanInteractor : UIPercentDrivenInteractiveTransition {
    let panGesture: UIPanGestureRecognizer
    let panSelector : Selector = "handlePanGesture:"
    let threshold: CGFloat = 0.25
    
    var containerView: UIView!
    
    init(_ panGesture: UIPanGestureRecognizer) {
        self.panGesture = panGesture
        super.init()
        panGesture.addTarget(self, action: panSelector)
    }
    
    deinit {
        panGesture.removeTarget(self, action: panSelector)
    }
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        containerView = transitionContext.containerView()
    }
    
    func handlePanGesture(pan: UIPanGestureRecognizer) {
        let point = pan.translationInView(containerView)
        let percent = abs(point.x / containerView.frame.width)
        switch pan.state {
        case .Changed:
            updateInteractiveTransition(percent)
        case .Ended, .Cancelled:
            if percent > threshold && pan.state != .Cancelled {
                finishInteractiveTransition()
            } else {
                cancelInteractiveTransition()
            }
        default:
            break
        }
    }
}