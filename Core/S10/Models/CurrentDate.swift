//
//  CurrentDate.swift
//  S10
//
//  Created by Tony Xiao on 6/28/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

// TODO: Implement this using RAC, make it not a global constant?
public let CurrentDate: Dynamic<NSDate> = {
    let dynamic = Dynamic(NSDate())
    RACSignal.interval(0.25, onScheduler: RACScheduler.mainThreadScheduler()).subscribeNext { date in
        dynamic.value = date as! NSDate
    }
    return dynamic
}()