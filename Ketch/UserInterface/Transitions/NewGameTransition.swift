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
    
    init(_ rootView: RootView, loadingVC: LoadingViewController, gameVC: GameViewController) {
        self.loadingVC = loadingVC
        self.gameVC = gameVC
        super.init(rootView, fromVC: loadingVC, toVC: gameVC)
    }

    override func animate() {
        super.animate()
        self.containerView.addSubview(self.toView!)
        spring(duration) {
            self.rootView.layoutIfNeeded()
            self.toView?.frame = self.context.finalFrameForViewController(self.gameVC)
            self.context.completeTransition(true)
        }
    }
}
