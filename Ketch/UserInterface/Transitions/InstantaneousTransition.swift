//
//  InstantaeousTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/7/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class InstantaneousTransition : RootTransition {
    
    init(fromVC: UIViewController, toVC: UIViewController) {
        super.init(fromVC: fromVC, toVC: toVC, duration: 0)
    }
    
    override func animate() {
//        if let vc = toVC as? BaseViewController {
//            rootView.waterlineLocation = vc.waterlineLocation
//        }
        containerView.addSubview(toView!)
        toView?.frame = context.finalFrameForViewController(toVC)
        fromView?.removeFromSuperview()
        // TODO: Async complete is needed to get around UINavigationController bug
        // where future push and pop would be all no-op for reason unknown
        dispatch_async(dispatch_get_main_queue()) {
            self.context.completeTransition(true)
        }
    }
}