//
//  WaveTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import ReactiveCocoa
import RBBAnimation

class WaveTransition : ViewControllerTransition {
    
    var fromWaveView: WaveView? {
        return fromView?.subviews.match { $0 is WaveView } as? WaveView
    }
    var toWaveView: WaveView? {
        return toView?.subviews.match { $0 is WaveView } as? WaveView
    }
    
    override func animate() {
        if fromWaveView != nil && toWaveView != nil {
            animateWithWave(duration)
        } else {
            containerView.addSubview(toView!)
            toView?.frame = context.finalFrameForViewController(toVC)
            toView?.alpha = 0
            
            UIView.animateSpring(duration) {
                self.toView?.alpha = 1
                self.fromView?.alpha = 0
            }.subscribeCompleted {
                if self.cancelled {
                    self.toView?.removeFromSuperview()
                }
                self.completeTransition()
            }
        }
    }
    
    func animateWithWave(duration: NSTimeInterval) {
        // Protect overshooting bottom edge
        let tallWave = WaveView(frame: fromWaveView!.frame)
        tallWave.frame.size.height += containerView.bounds.height
        containerView.insertSubview(tallWave, atIndex: 0)
        
        // Protect overshooting top edge
        let containerBackgroundColor = containerView.backgroundColor
        containerView.backgroundColor = toView?.backgroundColor
        
        // Compute Delta between waves
        toView?.frame = context.finalFrameForViewController(toVC)
        toView?.layoutSubviews()
        let delta = toWaveView!.frame.origin.y - fromWaveView!.frame.origin.y

        // Initial State
        toView?.frame.origin.y -= delta
        toView?.alpha = 0
        containerView.addSubview(toView!)
        
        UIView.animateSpring(duration) {
            self.fromView?.alpha = 0
            self.fromView?.frame.origin.y += delta
            self.toView?.alpha = 1
            self.toView?.frame.origin.y += delta
            tallWave.frame.origin.y += delta
        }.subscribeCompleted {
            // Remove overshoot protection
            tallWave.removeFromSuperview()
            self.containerView.backgroundColor = containerBackgroundColor
            // Handle cancellation
            if self.cancelled {
                self.toView?.removeFromSuperview()
            }
            // Finally complete
            self.completeTransition()
        }
    }
    
    func animateWaterline(duration: NSTimeInterval? = nil) -> RACSignal {
        return RACSignal.empty()
    }
}