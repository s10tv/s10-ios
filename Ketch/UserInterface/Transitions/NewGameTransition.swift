//
//  NewGameTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Spring

class NewGameTransition : RootTransition {
    let loadingVC : LoadingViewController
    let gameVC : GameViewController
    
    init(rootVC: RootViewController, loadingVC: LoadingViewController, gameVC: GameViewController) {
        self.loadingVC = loadingVC
        self.gameVC = gameVC
        super.init(rootVC: rootVC, fromVC: loadingVC, toVC: gameVC)
    }

    override func animate() {
        rootVC.rootView.updateHorizon(offset: 60)
        self.containerView.addSubview(self.toView!)
        spring(duration) {
            self.rootVC.rootView.layoutIfNeeded()
            self.toView?.frame = self.context.finalFrameForViewController(self.gameVC)
            self.context.completeTransition(true)
        }
    }
}
