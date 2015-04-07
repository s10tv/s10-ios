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