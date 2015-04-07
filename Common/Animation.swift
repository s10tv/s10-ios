//
//  Animation.swift
//  Ketch
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UIView {
    func setHiddenAnimated(#hidden: Bool, duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0) {
        UIView.animateWithDuration(duration, delay: delay, options: nil, animations: {
            if hidden {
                self.alpha = 0
            } else {
                self.hidden = false
                self.alpha = 1
            }
        }) { finished in
            if hidden && finished {
                self.hidden = true
            }
        }
    }
}

// Class Extensions
extension UIView {
    
    class func animateSpring(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
        return UIView.animateSpring(duration, delay: 0, animations: animations)
    }
    
    class func animateSpring(duration: NSTimeInterval, damping: CGFloat = 0.7, velocity: CGFloat = 0.7,
                        options: UIViewAnimationOptions = nil, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay,
            usingSpringWithDamping: damping, initialSpringVelocity: velocity,
            options: options, animations:animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
    
    class func animate(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
        return UIView.animate(duration, delay: 0, animations: animations)
    }
    
    class func animate(duration: NSTimeInterval, options: UIViewAnimationOptions = nil, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
}

// Animation block callback

extension CAAnimation {
    private class ProxyDelegate : NSObject {
        let subject = RACSubject()
        
        override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
            subject.sendNextAndCompleted(flag)
        }
    }
    
    // BUG NOTE: Trying to merge stopSignals is problematic. Next values are not being delivered

    // CAAnimation is an exception and actually retains its delegate, thus no need to use objc_associated_object
    var stopSignal : RACSignal {
        if !(delegate is ProxyDelegate) {
            delegate = ProxyDelegate()
        }
        return (delegate as ProxyDelegate).subject
    }
}

extension CATransaction {
    class func perform(animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        CATransaction.begin()
        animations()
        CATransaction.setCompletionBlock {
            subject.sendCompleted()
        }
        CATransaction.commit()
        return subject
    }
}