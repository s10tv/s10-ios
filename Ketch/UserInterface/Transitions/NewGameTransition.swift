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
    let waveDuration : NSTimeInterval = 1
    let bubbleDropDuration : NSTimeInterval = 1
    let bubbleDropInterval : NSTimeInterval = 0.1
    var gameVC : GameViewController { return toVC as! GameViewController }
    
    override func setup() {
        duration = waveDuration + bubbleDropDuration + bubbleDropDuration * 2
    }
    
    override func animate() -> RACSignal {
        self.containerView.addSubview(toView!)
        
        // Animate the wave and main screens up and down
        var signals = [animateWithWave(waveDuration)]
        
        // Animate the bubbles into water
        for (i, bubble) in enumerate(gameVC.bubbles) {
            let drop = RBBSpringAnimation(keyPath: "position.y")
            drop.fromValue = bubble.layer.position.y - gameVC.view.frame.height
            drop.toValue = bubble.layer.position.y
            drop.duration = bubbleDropDuration
            drop.beginTime = CACurrentMediaTime() + waveDuration + bubbleDropInterval * Double(i)
            drop.fillMode = kCAFillModeBackwards
            signals += drop.addToLayerAndReturnSignal(bubble.layer, forKey: "position.y")
        }
        
        // Clips to bounds so bubbles do not show up during animation
        toView?.clipsToBounds = true
        return RACSignal.merge(signals).doCompleted {
            self.toView?.clipsToBounds = false
            return
        }
    }
}
