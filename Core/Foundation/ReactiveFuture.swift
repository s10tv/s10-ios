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

public struct RACPromise<T, E: ErrorType> {

    private let sink: SinkOf<Event<T, E>>
    public let future: RACFuture<T, E>
    
    public init(_ block: ((RACPromise<T, E>) -> ())? = nil) {
        let (buffer, sink) = SignalProducer<T, E>.buffer(1)
        self.sink = sink
        future = RACFuture(buffer: buffer)
        block?(self)
    }
    
    public func complete(result: Result<T, E>) {
        assert(future.result == nil, "Promise should not be fulfulled multiple times")
        result.analysis(ifSuccess: {
            sendNext(sink, $0)
            sendCompleted(sink)
        }, ifFailure: {
            sendError(sink, $0)
        })
    }
    
    public func success(value: T) {
        complete(Result(value: value))
    }
    
    public func failure(error: E) {
        complete(Result(error: error))
    }
    
    public static func create<T, E: ErrorType>(@noescape block: (RACPromise<T, E> -> ())) -> RACFuture<T, E> {
        let promise = RACPromise<T, E>()
        block(promise)
        return promise.future
    }
}

public struct RACFuture<T, E: ErrorType> {
    private let buffer: SignalProducer<T, E>
    private let _result: () -> Result<T, E>?
    public var result: Result<T, E>? { return _result() }
    public var value: T? { return result?.value }
    public var error: E? { return result?.error }
    public var producer: SignalProducer<T, E> { return buffer }
    
    private init(buffer: SignalProducer<T, E>) {
        self.buffer = buffer
        var r: Result<T, E>?
        _result = { r }
        onComplete { r = $0 }
    }
    
    public init(workToStart: SignalProducer<T, E>) {
        let (buffer, sink) = SignalProducer<T, E>.buffer(1)
        workToStart |> take(1) |> start(sink)
        self.init(buffer: buffer)
    }
    
    public init(startedWork: Signal<T, E>) {
        let (buffer, sink) = SignalProducer<T, E>.buffer(1)
        startedWork |> take(1) |> observe(sink)
        self.init(buffer: buffer)
    }
    
    public func onComplete(_ deliverOn: SchedulerType? = nil, callback: Result<T, E> ->()) -> Disposable {
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
    
    public func on(_ deliverOn: SchedulerType? = nil, success: (T -> ())? = nil, failure: (E -> ())? = nil, complete: (() -> ())? = nil) -> Disposable {
        return onComplete(deliverOn) { result in
            result.analysis(ifSuccess: { success?($0) }, ifFailure: { failure?($0) })
            complete?()
        }
    }
    
    public func onSuccess(_ deliverOn: SchedulerType? = nil, callback: T -> ()) -> Disposable {
        return on(deliverOn, success: callback)
    }
    
    public func onFailure(_ deliverOn: SchedulerType? = nil, callback: E -> ()) -> Disposable {
        return on(deliverOn, failure: callback)
    }
    
    // Unary lift
    
    public func lift<U, F>(transform: Signal<T, E> -> Signal<U, F>) -> RACFuture<U, F> {
        return RACFuture<U, F>(buffer: buffer.lift(transform))
    }
    
    public func lift<U, F>(transform: SignalProducer<T, E> -> SignalProducer<U, F>) -> RACFuture<U, F> {
        return RACFuture<U, F>(buffer: transform(buffer))
    }
    
    // Binary lift
    
    public func lift<U, F, V, G>(transform: Signal<U, F> -> (Signal<T, E> -> Signal<V, G>)) -> RACFuture<U, F> -> RACFuture<V, G> {
        return { otherFuture in
            return RACFuture<V, G>(buffer: self.buffer.lift(transform)(otherFuture.buffer))
        }
    }
    
    public func lift<U, F, V, G>(transform: SignalProducer<U, F> -> (SignalProducer<T, E> -> SignalProducer<V, G>)) -> RACFuture<U, F> -> RACFuture<V, G> {
        return { otherFuture in
            return RACFuture<V, G>(buffer: transform(otherFuture.buffer)(self.buffer))
        }
    }
}

public func |> <T, E, X>(future: RACFuture<T, E>, @noescape transform: RACFuture<T, E> -> X) -> X {
    return transform(future)
}

public func onSuccess<T, E>(block: T -> ()) -> RACFuture<T, E> -> RACFuture<T, E> {
    return { future in
        future.onSuccess(callback: block)
        return future
    }
}

public func onFailure<T, E>(block: E -> ()) -> RACFuture<T, E> -> RACFuture<T, E> {
    return { future in
        future.onFailure(callback: block)
        return future
    }
}

public func onComplete<T, E>(block: Result<T, E> -> ()) -> RACFuture<T, E> -> RACFuture<T, E> {
    return { future in
        future.onComplete(callback: block)
        return future
    }
}

// Unary Lift

public func |> <T, E, U, F>(future: RACFuture<T, E>, transform: Signal<T, E> -> Signal<U, F>) -> RACFuture<U, F> {
    return future.lift(transform)
}

public func |> <T, E, U, F>(future: RACFuture<T, E>, transform: SignalProducer<T, E> -> SignalProducer<U, F>) -> RACFuture<U, F> {
    return future.lift(transform)
}

// Convert from signal producer & signal

public func toFuture<T, E: ErrorType>(producer: SignalProducer<T, E>) -> RACFuture<T, E> {
    return RACFuture(workToStart: producer)
}

public func toFuture<T, E: ErrorType>(signal: Signal<T, E>) -> RACFuture<T, E> {
    return RACFuture(startedWork: signal)
}


// Deprecated

public func future<T, E>(deliverOn: SchedulerType? = nil, success: (T -> ())? = nil, failure: (E -> ())? = nil, complete: (Result<T, E> -> ())? = nil) -> SignalProducer<T, E> -> Disposable {
    return { producer in
        return RACFuture(workToStart: producer).onComplete(deliverOn) { result in
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

public func futureSuccess<T, E>(_ deliverOn: SchedulerType? = nil, callback: T -> ()) -> SignalProducer<T, E> -> Disposable {
    return future(deliverOn: deliverOn, success: callback)
}

public func futureFailure<T, E>(_ deliverOn: SchedulerType? = nil, callback: E -> ()) -> SignalProducer<T, E> -> Disposable {
    return future(deliverOn: deliverOn, failure: callback)
}

public func futureCompleted<T, E>(_ deliverOn: SchedulerType? = nil, callback: Result<T, E> -> ()) -> SignalProducer<T, E> -> Disposable {
    return future(deliverOn: deliverOn, complete: callback)
}
