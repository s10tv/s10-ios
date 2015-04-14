//
//  WaveTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import ReactiveCocoa

class WaveTransition : ViewControllerTransition {
    
    override func animate() {
        // NOTE: HACK for now... Need to get rid of rootView
        // Necessary for showing waterline in the right spot when going from waitlist to chat
//        if fromVC is WaitlistViewController && toVC is ChatViewController {
//            rootView.waterlineLocation = .Top(60)
//        }
        
//        if let vc = toVC as? BaseViewController {
//            rootView.waterlineLocation = vc.waterlineLocation
//        }
        containerView.addSubview(toView!)
        toView?.frame = context.finalFrameForViewController(toVC)
        toView?.alpha = 0
        fromView?.alpha = 1
        UIView.animateSpring(duration) {
            self.toView?.alpha = 1
            self.fromView?.alpha = 0
//            self.rootView.layoutIfNeeded()
        }.subscribeNextAs { (finished: Bool) in
            self.context.completeTransition(finished)
        }
    }
    
    func animateWaterline(duration: NSTimeInterval? = nil) -> RACSignal {
//        if let vc = toVC as? BaseViewController {
//            rootView.waterlineLocation = vc.waterlineLocation
//            return UIView.animateSpring(duration ?? self.duration) {
//                self.rootView.layoutIfNeeded()
//            }
//        }
        return RACSignal.empty()
    }
}