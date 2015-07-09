//
//  RACExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Box

// MARK: - RAC3 Extensions

struct RACPromise<T, E : ErrorType> {
    private let sink: SinkOf<Event<T, E>>
    let future: SignalProducer<T, E>
    
    init() {
        (future, sink) = SignalProducer<T, E>.buffer(1)
    }
    
    func success(value: T) {
        sendNext(sink, value)
        sendCompleted(sink)
    }
    
    func error(error: E) {
        sendError(sink, error)
    }
    
    func cancel() {
        sendInterrupted(sink)
    }
}

/*public*/
extension SignalProducer {
    typealias SuccessCallback = T -> ()
    typealias ErrorCallback = E -> ()
    typealias CancelCallback = () -> ()
    typealias FinishCallback = Event<T, E> -> ()
    
    func onSuccess(callback: SuccessCallback) -> SignalProducer {
        var value: T?
        start(completed: {
            callback(value!)
        }, next: {
            assert(value == nil, "Only one value should be sent for future")
            value = $0
        })
        return self
    }
    
    func onError(callback: ErrorCallback) -> SignalProducer {
        start(error: callback)
        return self
    }
    
    func onCancel(callback: CancelCallback) -> SignalProducer {
        start(interrupted: callback)
        return self
    }
    
    func onFinish(callback: FinishCallback) -> SignalProducer {
        var value: T?
        start(error: {
            callback(.Error(Box($0)))
        }, completed: {
            callback(.Next(Box(value!)))
        }, interrupted: {
            callback(.Interrupted)
        }, next: {
            assert(value == nil, "Only one value should be sent for future")
            value = $0
        })
        return self
    }
}
