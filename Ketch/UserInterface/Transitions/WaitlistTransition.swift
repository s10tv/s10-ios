//
//  WaitlistTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class WaitlistTransition : WaveTransition {
    let loadingVC : LoadingViewController
    let waitlistVC : WaitlistViewController
    
    init(loadingVC: LoadingViewController, waitlistVC: WaitlistViewController) {
        self.loadingVC = loadingVC
        self.waitlistVC = waitlistVC
        super.init(fromVC: loadingVC, toVC: waitlistVC)
    }
    
    override func animate() {
//        rootView.waterlineLocation = waitlistVC.waterlineLocation
        self.containerView.addSubview(self.toView!)
        UIView.animateSpring(duration) {
//            self.rootView.layoutIfNeeded()
            self.toView?.frame = self.context.finalFrameForViewController(self.waitlistVC)
            self.context.completeTransition(true)
        }
    }
}