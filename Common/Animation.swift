//
//  Animation.swift
//  Ketch
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import ReactiveCocoa

func spring(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
    let subject = RACSubject()
    UIView.animateWithDuration(duration,
        delay: 0,
        usingSpringWithDamping: 0.7,
        initialSpringVelocity: 0.7,
        options: nil,
        animations:animations) { finished in
            subject.sendNextAndCompleted(finished)
    }
    return subject
}

extension UIView {
    
    class func animate(duration: NSTimeInterval, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        return UIView.animate(duration, delay: delay, options: nil, animations: animations)
    }
    
    class func animate(duration: NSTimeInterval, delay: NSTimeInterval = 0, options: UIViewAnimationOptions = nil, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
}