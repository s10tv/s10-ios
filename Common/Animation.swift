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


