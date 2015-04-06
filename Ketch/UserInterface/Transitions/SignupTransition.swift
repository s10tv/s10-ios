//
//  SignupTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class SignupTransition : RootTransition {
    let loadingVC : LoadingViewController
    let signupVC : SignupViewController
    
    init(_ rootView: RootView, loadingVC: LoadingViewController, signupVC: SignupViewController) {
        self.loadingVC = loadingVC
        self.signupVC = signupVC
        super.init(rootView, fromVC: loadingVC, toVC: signupVC)
    }
    
    override func animate() {
        rootView.waterlineLocation = signupVC.waterlineLocation
        self.containerView.addSubview(self.toView!)
        spring(duration) {
            self.rootView.layoutIfNeeded()
            self.toView?.frame = self.context.finalFrameForViewController(self.signupVC)
            self.context.completeTransition(true)
        }
    }
}