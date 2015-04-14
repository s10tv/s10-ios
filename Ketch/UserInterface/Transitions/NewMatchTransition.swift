//
//  NewMatchTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/2/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import RBBAnimation

class NewMatchTransition : WaveTransition {
    
    init(fromVC: UIViewController, toVC: UIViewController) {
        super.init(fromVC: fromVC, toVC: toVC, duration: 2)
    }
    
    override func animate() {
        let matchVC = toVC as NewConnectionViewController
        containerView.addSubview(matchVC.view)
        matchVC.view.frame = context.finalFrameForViewController(matchVC)
        matchVC.view.layoutSubviews()
        
        // Animate waterline
        let finalY = matchVC.waveView.frame.origin.y
//        matchVC.waveView.frame.origin.y = rootView.waveView.frame.origin.y
        
        UIView.animateSpring(1) {
            matchVC.waveView.frame.origin.y = finalY
        }
        
        // Animate avatar
        let avatar = matchVC.avatar.layer
        let pop = RBBSpringAnimation(keyPath: "position.y")
        pop.fromValue = avatar.position.y + containerView.frame.height
        pop.toValue = avatar.position.y
        pop.duration = duration
//        pop.stiffness = 10
        pop.velocity = 1
        pop.mass = 0.5
        pop.damping = 5
        pop.fillMode = kCAFillModeBackwards
        pop.addToLayerAndReturnSignal(avatar, forKey: "position.y").subscribeCompleted {
            self.context.completeTransition(true)
        }
        avatar.addAnimation(pop, forKey: "position.y")
    }
}