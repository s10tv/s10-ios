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

    private let sink: SinkOf<Event<T, E>>
    let future: RACFuture<T, E>
    
    init() {
        let (buffer, sink) = SignalProducer<T, E>.buffer(1)
        self.sink = sink
        future = RACFuture(buffer: buffer)
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
    private let buffer: SignalProducer<T, E>
    private let deliverOn: SchedulerType?
    private let _result: () -> Result<T, E>?
    var result: Result<T, E>? { return _result() }
    var value: T? { return result?.value }
    var error: E? { return result?.error }
    var producer: SignalProducer<T, E> { return buffer }
    
    private init(buffer: SignalProducer<T, E>, deliverOn: SchedulerType? = nil) {
        self.buffer = buffer
        self.deliverOn = deliverOn
        var r: Result<T, E>?
        _result = { r }
        onComplete { r = $0 }
    }
    
    init(workToStart: SignalProducer<T, E>, deliverOn: SchedulerType? = nil) {
        let (buffer, sink) = SignalProducer<T, E>.buffer(1)
        workToStart |> take(1) |> start(sink)
        self.init(buffer: buffer, deliverOn: deliverOn)
    }
    
    init(startedWork: Signal<T, E>, deliverOn: SchedulerType? = nil) {
        let (buffer, sink) = SignalProducer<T, E>.buffer(1)
        startedWork |> take(1) |> observe(sink)
        self.init(buffer: buffer, deliverOn: deliverOn)
    }
    
    func onComplete(callback: Result<T, E> ->()) -> Disposable {
        var result: Result<T, E>?
        let sink = Event<T, E>.sink(next: { v in
            result = Result(value: v)
        }, completed: {
            callback(result!)
        }, error: { e in
            result = Result(error: e)
            callback(result!)
        })
        var disposable: Disposable!
        buffer.startWithSignal { signal, innerDisposable in
            (deliverOn.map { signal |> observeOn($0) } ?? signal).observe(sink)
            disposable = innerDisposable
        }
        return disposable
    }
    
    func onSuccess(callback: T -> ()) -> Disposable {
        return onComplete { result in
            result.analysis(ifSuccess: callback, ifFailure: { _ in })
        }
    }
    
    func onFailure(callback: E -> ()) -> Disposable {
        return onComplete { result in
            result.analysis(ifSuccess: { _ in }, ifFailure: callback)
        }
    }
}

func |> <T, E: ErrorType>(producer: SignalProducer<T, E>, transform: SignalProducer<T, E> -> RACFuture<T, E>) -> RACFuture<T, E> {
    return transform(producer)
}

func toFuture<T, E: ErrorType>(producer: SignalProducer<T, E>) -> RACFuture<T, E> {
    return RACFuture(workToStart: producer)
}

func |> <T, E: ErrorType>(signal: Signal<T, E>, transform: Signal<T, E> -> RACFuture<T, E>) -> RACFuture<T, E> {
    return transform(signal)
}

func toFuture<T, E: ErrorType>(signal: Signal<T, E>) -> RACFuture<T, E> {
    return RACFuture(startedWork: signal)
}

func future<T, E>(deliverOn: SchedulerType? = nil, success: (T -> ())? = nil, failure: (E -> ())? = nil, complete: (Result<T, E> -> ())? = nil) -> SignalProducer<T, E> -> Disposable {
    return { producer in
        return RACFuture(workToStart: producer, deliverOn: deliverOn).onComplete { result in
            switch result {
            case .Success(let v):
                success?(v.value)
            case .Failure(let error):
                failure?(error.value)
            }
            complete?(result)
        }
    }
}

func futureSuccess<T, E>(_ deliverOn: SchedulerType? = nil, callback: T -> ()) -> SignalProducer<T, E> -> Disposable {
    return future(deliverOn: deliverOn, success: callback)
}

func futureFailure<T, E>(_ deliverOn: SchedulerType? = nil, callback: E -> ()) -> SignalProducer<T, E> -> Disposable {
    return future(deliverOn: deliverOn, failure: callback)
}

func futureCompleted<T, E>(_ deliverOn: SchedulerType? = nil, callback: Result<T, E> -> ()) -> SignalProducer<T, E> -> Disposable {
    return future(deliverOn: deliverOn, complete: callback)
}
