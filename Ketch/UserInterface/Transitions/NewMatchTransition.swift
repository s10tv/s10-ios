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

class NewMatchTransition : SailAwayTransition {
    let popDuration: NSTimeInterval = 2
    
    override func setup() {
        duration = boatDuration + popDuration
    }
    
    func animateAvatarPop() -> RACSignal {
        let avatar = (toVC as NewConnectionViewController).avatar.layer
        
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
        popOutOfWater.duration = popDuration
        popOutOfWater.animations = [springUp, sendToBack]
        
        return popOutOfWater.addToLayerAndReturnSignal(avatar, forKey: "popOutOfWater")
    }
    
    override func animate() -> RACSignal {
        return animateBoatAway().then {
            self.containerView.addSubview(self.toView!)
            return RACSignal.merge([
                self.animateWithWave(self.popDuration/2),
                self.animateAvatarPop()
            ])
        }
    }
}