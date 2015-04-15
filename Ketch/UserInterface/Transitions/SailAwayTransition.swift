//
//  SailAwayTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

class SailAwayTransition : WaveTransition {
    let boatDuration: NSTimeInterval = 1
    
    override func setup() {
        duration = 2
    }
    
    override func animate() -> RACSignal {
        let boat = fromView!.subviews.match { $0 is KetchBoatView } as KetchBoatView
        
        return boat.layer.animate(keyPath: "position.x") { xPos, _ in
            xPos.byValue = self.fromView!.bounds.width
            xPos.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            xPos.duration = self.boatDuration
            xPos.fillMode = kCAFillModeForwards
            xPos.removedOnCompletion = false
        }.then {
            self.containerView.addSubview(self.toView!)
            return self.animateWithWave(self.duration - self.boatDuration)
        }.doCompleted {
            // Not clear to me why this is needed because after getting removed from superview
            // boat is suppose to not have any associated animation anymore
            boat.layer.removeAnimationForKey("position.x")
            boat.animatePitch() // For some reason pitch gets removed
        }
    }
}