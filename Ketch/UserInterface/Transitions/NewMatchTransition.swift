//
//  NewMatchTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/2/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import RBBAnimation
import ReactiveCocoa

class NewMatchTransition : WaveTransition {
    
    override func setup() {
        duration = 2
    }
    
    override func animate() -> RACSignal {
        let matchVC = toVC as NewConnectionViewController
        
        containerView.addSubview(toView!)
        
        // Animate the wave and layout views
        let signals = [animateWithWave(duration/2)]
        
        // Animate avatar to pop out of water
        let avatar = matchVC.avatar.layer
        let springUp = RBBSpringAnimation(keyPath: "position.y")
        springUp.fromValue = avatar.position.y + containerView.frame.height
        springUp.toValue = avatar.position.y
        springUp.velocity = 1
        springUp.mass = 0.5
        springUp.damping = 5
        springUp.fillMode = kCAFillModeBackwards
        
        let sendToBack = CABasicAnimation("zPosition")
        sendToBack.fromValue = 0.2 // Precisely selected so avatar goes back after first bounce
        sendToBack.toValue = -1
        
        let popOutOfWater = CAAnimationGroup()
        popOutOfWater.duration = duration
        popOutOfWater.animations = [springUp, sendToBack]
        
        return popOutOfWater.addToLayerAndReturnSignal(avatar, forKey: "popOutOfWater")
    }
}