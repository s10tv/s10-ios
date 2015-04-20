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
    var boat: KetchBoatView {
        return fromView!.subviews.match { $0 is KetchBoatView } as KetchBoatView
    }
    
    override func setup() {
        duration = 2
    }
    
    func animateBoatAway() -> RACSignal {
        return boat.layer.animate(keyPath: "position.x") { xPos, _ in
            xPos.byValue = self.fromView!.bounds.width
            xPos.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            xPos.duration = self.boatDuration
            xPos.fillMode = kCAFillModeForwards
            xPos.removedOnCompletion = false
        }
    }
    
    override func animate() -> RACSignal {
        return animateBoatAway().then {
            self.containerView.addSubview(self.toView!)
            return self.animateWithWave(self.duration - self.boatDuration)
        }
    }
    
    override func completeTransition() {
        // Not clear to me why this is needed because after getting removed from superview
        // boat is suppose to not have any associated animation anymore
        self.boat.layer.removeAnimationForKey("position.x")
        self.boat.animateAlongWave() // For some reason pitch gets removed
        super.completeTransition()
    }
}