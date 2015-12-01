//
//  ReactExtensions.swift
//  Taylr
//
//  Created by Tony Xiao on 11/23/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import React
import ReactiveCocoa

extension SignalProducer {

    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func promise(resolve: RCTPromiseResolveBlock, _ reject: RCTPromiseRejectBlock) -> SignalProducer {
        // NOTE: Not thread-safe
        var resolved = false
        return on(error: { error in
            reject(error as NSError)
        }, completed: {
            if !resolved {
                resolve(nil)
                resolved = true
            }
        }, next: { value in
            if !resolved {
                resolve(value as? AnyObject)
                resolved = true
            }
        })
    }
}