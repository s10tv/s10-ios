//
//  ReactiveFuture.swift
//  S10
//
//  Created by Tony Xiao on 7/14/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

struct RACPromise<T, E: ErrorType> {

    let future: RACFuture<T, E>
    let sink: SinkOf<Event<T, E>>
    
    init() {
        let (producer, sink) = SignalProducer<T, E>.buffer(1)
        self.sink = sink
        future = RACFuture(producer)
    }
    
    func success(value: T) {
        sendNext(sink, value)
        sendCompleted(sink)
    }
    
    func failure(error: E) {
        sendError(sink, error)
    }
}

struct RACFuture<T, E: ErrorType> {
    private let _result: () -> Result<T, E>?
    
    let producer: SignalProducer<T, E>
    var result: Result<T, E>? { return _result() }
    var value: T? { return result?.value }
    var error: E? { return result?.error }
    
    init(_ producer: SignalProducer<T, E>) {
        self.producer = producer |> take(1)
        var r: Result<T, E>?
        _result = { r }
        onComplete { r = $0 }
    }
    
    func onComplete(callback: Result<T, E> ->()) -> Disposable {
        var result: Result<T, E>?
        return producer.start(next: { v in
            result = Result(value: v)
        }, completed: {
            callback(result!)
        }, error: { e in
            result = Result(error: e)
            callback(result!)
        })
    }
    
    func onSuccess(callback: T -> ()) {
        onComplete { result in
            result.analysis(ifSuccess: callback, ifFailure: { _ in })
        }
    }
    
    func onFailure(callback: E -> ()) {
        onComplete { result in
            result.analysis(ifSuccess: { _ in }, ifFailure: callback)
        }
    }
}
