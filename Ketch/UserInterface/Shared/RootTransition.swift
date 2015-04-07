//
//  RootTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import ReactiveCocoa

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
        UIView.animateSpring(duration) {
            self.toView?.alpha = 1
            self.fromView?.alpha = 0
            self.rootView.layoutIfNeeded()
        }.subscribeNextAs { (finished: Bool) in
            self.context.completeTransition(finished)
        }
    }
    
    func animateWaterline() -> RACSignal {
        if let vc = toVC as? BaseViewController {
            rootView.waterlineLocation = vc.waterlineLocation
            return UIView.animateSpring(duration) {
                self.rootView.layoutIfNeeded()
            }
        }
        return RACSignal.empty()
    }
}