//
//  WaitlistTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class WaitlistTransition : RootTransition {
    let loadingVC : LoadingViewController
    let waitlistVC : WaitlistViewController
    
    init(_ rootView: RootView, loadingVC: LoadingViewController, waitlistVC: WaitlistViewController) {
        self.loadingVC = loadingVC
        self.waitlistVC = waitlistVC
        super.init(rootView, fromVC: loadingVC, toVC: waitlistVC)
    }
    
    override func animate() {
        rootView.waterlineLocation = waitlistVC.waterlineLocation
        self.containerView.addSubview(self.toView!)
        spring(duration) {
            self.rootView.layoutIfNeeded()
            self.toView?.frame = self.context.finalFrameForViewController(self.waitlistVC)
            self.context.completeTransition(true)
        }
    }
}