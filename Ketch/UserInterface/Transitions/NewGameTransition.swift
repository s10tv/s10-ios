//
//  NewGameTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import RBBAnimation
import ReactiveCocoa

class NewGameTransition : WaveTransition {
    let loadingVC : LoadingViewController
    let gameVC : GameViewController
    let waterlineDuration : NSTimeInterval = 1
    let bubbleDropDuration : NSTimeInterval = 1
    let bubbleDropInterval : NSTimeInterval = 0.1
    let operation: UINavigationControllerOperation
    
    init(loadingVC: LoadingViewController, gameVC: GameViewController, operation: UINavigationControllerOperation) {
        self.loadingVC = loadingVC
        self.gameVC = gameVC
        self.operation = operation
        var duration = waterlineDuration + bubbleDropDuration + bubbleDropDuration * 2
        var from : UIViewController = loadingVC
        var to : UIViewController = gameVC
        if operation == .Pop {
            duration = waterlineDuration
            from = gameVC
            to = loadingVC
        }
        super.init(fromVC: from, toVC: to, duration: duration)
    }
    
    override func animate() {
        switch operation {
        case .Push:
            animateStartGame()
        case .Pop:
            animateFinishGame()
        default:
            break
        }
    }

    func animateStartGame() {
        self.containerView.addSubview(toView!)
        toView?.frame = self.context.finalFrameForViewController(self.gameVC)
        toView?.layoutIfNeeded()

        // It is ok to use forward fill mode here because fromView will be removed from 
        // view hierarchy and thus all animations will be removed, avoiding leading
        // presentation and model in an inconsistent state
        var signals = [
            animateWaterline(duration: waterlineDuration),
            fromView!.layer.animateOpacity(0, duration: 0.25, fillMode: .Forwards)
        ]
        
        // Fade the navigation buttons in
        for view in gameVC.navViews {
            let animation = CABasicAnimation("opacity", fillMode: .Backwards)
            animation.fromValue = 0
            animation.duration = waterlineDuration
            signals += animation.addToLayerAndReturnSignal(view.layer, forKey: "opacity")
        }
        
        // Make the placerholder fall
        for placeholder in gameVC.placeholders {
            let animation = RBBSpringAnimation(keyPath: "position.y")
            animation.fromValue = placeholder.layer.position.y + containerView.frame.height
            animation.toValue = placeholder.layer.position.y
            animation.duration = waterlineDuration
            animation.damping = 15
            signals += animation.addToLayerAndReturnSignal(placeholder.layer, forKey: "position.y")
        }
        
        // Animate the bubbles into water
        for (i, bubble) in enumerate(gameVC.bubbles) {
            let drop = RBBSpringAnimation(keyPath: "position.y")
            drop.fromValue = bubble.layer.position.y - gameVC.view.frame.height
            drop.toValue = bubble.layer.position.y
            drop.duration = bubbleDropDuration
            drop.beginTime = CACurrentMediaTime() + waterlineDuration + bubbleDropInterval * Double(i)
            drop.fillMode = kCAFillModeBackwards
            signals += drop.addToLayerAndReturnSignal(bubble.layer, forKey: "position.y")
        }
        
        // BUG ALERT: We assume transition is complete, but are there situations where
        // this is actually not true? What about interactive view controller transition?
        RACSignal.merge(signals).subscribeCompleted {
            self.context.completeTransition(true)
        }
    }
    
    func animateFinishGame() {
        self.containerView.addSubview(toView!)
        toView?.frame = containerView.bounds
        toView?.layoutSubviews()
        
        var signals = [animateWaterline()]

        // Fade the loading view in
        let fadeIn = CABasicAnimation("opacity", duration: waterlineDuration, fillMode: .Backwards)
        fadeIn.fromValue = 0
        signals += fadeIn.addToLayerAndReturnSignal(toView!.layer, forKey: "opacity")

        // Fade nav buttons out
        let fadeOut = CABasicAnimation("opacity", duration: waterlineDuration, fillMode: .Forwards)
        fadeOut.toValue = 1
        for view in gameVC.navViews {
            signals += fadeOut.addToLayerAndReturnSignal(view.layer, forKey: "opacity")
        }
        
        // Drop the main view down long with the waterline
        let drop = RBBSpringAnimation(keyPath: "position.y")
        drop.fromValue = fromView!.layer.position.y
        drop.toValue = fromView!.layer.position.y + containerView.frame.height
        drop.duration = waterlineDuration
        drop.fillMode = kCAFillModeForwards
        drop.removedOnCompletion = false
        signals += drop.addToLayerAndReturnSignal(fromView!.layer, forKey: "position.y")
        
        // BUG ALERT: We assume transition is complete, but are there situations where
        // this is actually not true? What about interactive view controller transition?
        RACSignal.merge(signals).subscribeCompleted {
            self.context.completeTransition(true)
        }
    }
}
