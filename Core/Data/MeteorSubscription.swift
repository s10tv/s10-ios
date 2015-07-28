//
//  MeteorSubscription.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

public class MeteorSubscription {
    private let subscription: METSubscription
    private let meteor: METDDPClient
    public let ready: RACFuture<(), NSError>
    
    public init(meteor: METDDPClient, subscription: METSubscription) {
        self.meteor = meteor
        self.subscription = subscription
        ready = RACPromise { promise in
            subscription.whenDone {
                if let error = $0 {
                    promise.failure(error)
                } else {
                    promise.success()
                }
            }
        }.future
    }
    
    deinit {
        meteor.removeSubscription(subscription)
    }
}

public class MeteorMethod {
    public let stubValue: AnyObject?
    public let future: RACFuture<AnyObject?, NSError>
    
    public init(stubValue: AnyObject?, future: RACFuture<AnyObject?, NSError>) {
        self.stubValue = stubValue
        self.future = future
    }
}