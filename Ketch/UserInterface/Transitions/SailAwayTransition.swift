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
        return UIView.animate(boatDuration, options: .CurveEaseIn) {
            self.boat.frame.origin.x += self.fromView!.bounds.width
        }.doCompleted {
            self.boat.hidden = true
        }
    }
    
    override func animate() -> RACSignal {
        return animateBoatAway().then {
            self.containerView.addSubview(self.toView!)
            return self.animateWithWave(self.duration - self.boatDuration)
        }
    }
    
    override func completeTransition() {
        super.completeTransition()
        boat.hidden = false
    }
}