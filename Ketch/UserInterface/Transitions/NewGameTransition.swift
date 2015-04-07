//
//  NewGameTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import RBBAnimation

class NewGameTransition : RootTransition {
    let loadingVC : LoadingViewController
    let gameVC : GameViewController
    
    init(_ rootView: RootView, loadingVC: LoadingViewController, gameVC: GameViewController) {
        self.loadingVC = loadingVC
        self.gameVC = gameVC
        super.init(rootView, fromVC: loadingVC, toVC: gameVC, duration: 1)
    }

    override func animate() {
        rootView.waterlineLocation = gameVC.waterlineLocation
        self.containerView.addSubview(toView!)
        toView?.layoutIfNeeded()
        for (i, bubble) in enumerate(gameVC.bubbles) {
            let drop = RBBSpringAnimation(keyPath: "position.y")
            drop.fromValue = bubble.layer.position.y - gameVC.view.frame.height
            drop.toValue = bubble.layer.position.y
            drop.duration = duration
            drop.beginTime = CACurrentMediaTime() + Double(i) * 0.1
            drop.fillMode = kCAFillModeBackwards
            bubble.layer.addAnimation(drop, forKey: "position.y")
        }
        UIView.animateSpring(duration+0.2) {
            self.rootView.layoutIfNeeded()
            self.toView?.frame = self.context.finalFrameForViewController(self.gameVC)
            self.context.completeTransition(true)
        }
    }
}
