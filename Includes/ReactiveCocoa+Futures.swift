//
//  ReactiveCocoa+Futures.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import BrightFutures

extension SignalProducer {
    func future() -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        start(error: {
            promise.failure($0.nsError)
            }, next: {
                promise.success($0)
        })
        return promise.future
    }
}