//
//  PanInteractor.swift
//  Taylr
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit

public class PanInteractor : UIPercentDrivenInteractiveTransition {
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
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        containerView = transitionContext.containerView()
        super.startInteractiveTransition(transitionContext)
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