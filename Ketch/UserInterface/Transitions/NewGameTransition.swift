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

class NewGameTransition : RootTransition {
    let loadingVC : LoadingViewController
    let gameVC : GameViewController
    
    init(_ rootView: RootView, loadingVC: LoadingViewController, gameVC: GameViewController) {
        self.loadingVC = loadingVC
        self.gameVC = gameVC
        super.init(rootView, fromVC: loadingVC, toVC: gameVC, duration: 1)
    }

    override func animate() {
        self.containerView.addSubview(toView!)
        toView?.frame = self.context.finalFrameForViewController(self.gameVC)
        toView?.layoutIfNeeded()
        
        var signals = [animateWaterline()]
        
        // Animate the bubbles into water
        let delay : NSTimeInterval = 0.1
        for (i, bubble) in enumerate(gameVC.bubbles) {
            let drop = RBBSpringAnimation(keyPath: "position.y")
            drop.fromValue = bubble.layer.position.y - gameVC.view.frame.height
            drop.toValue = bubble.layer.position.y
            drop.duration = duration - delay * Double(gameVC.bubbles.count - 1)
            drop.beginTime = CACurrentMediaTime() + Double(i) * delay
            drop.fillMode = kCAFillModeBackwards
            // CAAnimation has value semantic, must save signal prior to adding to layer
            signals += drop.stopSignal
            bubble.layer.addAnimation(drop, forKey: "position.y")
        }
        
        // BUG ALERT: We assume transition is complete, but are there situations where
        // this is actually not true? What about interactive view controller transition?
        RACSignal.merge(signals).subscribeCompleted {
            self.context.completeTransition(true)
        }
    }
    
}
