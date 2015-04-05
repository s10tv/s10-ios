//
//  RootTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import Spring

class RootTransition : ViewControllerTransition {
    let rootView : RootView
    
    init(_ rootView: RootView, fromVC: UIViewController, toVC: UIViewController, duration: NSTimeInterval = 0.6) {
        self.rootView = rootView
        super.init(fromVC: fromVC, toVC: toVC, duration: duration)
    }
    
    override func animate() {
        if let vc = toVC as? BaseViewController {
            rootView.waterlineLocation = vc.waterlineLocation
        }
        containerView.addSubview(toView!)
        toView?.frame = context.finalFrameForViewController(toVC)
        toView?.alpha = 0
        fromView?.alpha = 1
        springWithCompletion(duration, {
            self.toView?.alpha = 1
            self.fromView?.alpha = 0
            self.rootView.layoutIfNeeded()
            }) { completed in
                self.context.completeTransition(true)
        }
    }
}