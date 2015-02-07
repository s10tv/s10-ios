//
//  MeteorExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Meteor
import ReactiveCocoa

//extension
extension METSubscription {
    
    var signal : RACSignal {
        let subject = RACReplaySubject()
        whenDone { (err) -> Void in
            err != nil ? subject.sendError(err) : subject.sendCompleted()
        }
        return subject
    }
}
