//
//  ReactiveBridging.swift
//  S10
//
//  Created by Tony Xiao on 7/13/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import BrightFutures
import Bond
import Box

// MARK: - ReactiveCocoa + SwiftBonds

func toBondDynamic<T, P: PropertyType where P.Value == T>(property: P) -> Dynamic<T> {
    let dyn = InternalDynamic<T>(property.value)
    dyn.retain(Box(property))
    property.producer.start(next: { value in
        dyn.value = value
    })
    return dyn
}

// Bind and fire

func ->> <T: PropertyType, U: Bondable where T.Value == U.BondType>(left: T, right: U) {
    toBondDynamic(left) ->> right.designatedBond
}

// Bind only

func ->| <T: PropertyType, U: Bondable where T.Value == U.BondType>(left: T, right: U) {
    toBondDynamic(left) ->| right.designatedBond
}

// MARK: ReactiveCocoa + BrightFutures

let errSignalInterrupted = NSError(domain: "ReactiveCocoa", code: NSUserCancelledError, userInfo: nil)

extension SignalProducer {
    func future() -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        var value: T?
        start(error: {
            promise.failure($0.nsError)
            }, interrupted: {
                promise.failure(errSignalInterrupted)
            }, completed: {
                if let value = value {
                    promise.success(value)
                } else {
                    promise.success(() as! T)
                }
            }, next: {
                assert(value == nil, "future should only have 1 value")
                value = $0
        })
        return promise.future
    }
}

extension Future {
    func signalProducer() -> SignalProducer<T, NSError> {
        // TODO: Make more sense of memory management
        return SignalProducer { sink, disposable in
            // Local variable to work around swiftc compilation bug
            // http://www.markcornelisse.nl/swift/swift-invalid-linkage-type-for-function-declaration/
            let successBlock: T -> () = {
                sendNext(sink, $0)
                sendCompleted(sink)
            }
            self.onSuccess(callback: successBlock).onFailure {
                sendError(sink, $0.nsError)
            }
        }
    }
}
