//
//  RACGenericExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import Core

// MARK: - Action extension

extension Action {
    
    convenience init(_ future: Input -> Future<Output, Error>) {
        self.init(enabledIf: ConstantProperty(true), { input in
            SignalProducer<Output, Error> { observer, disposable in
                disposable += future(input).producer.start(observer)
            }
        })
    }
    
    convenience init(_ transform: Input -> Result<Output, Error>) {
        self.init(enabledIf: ConstantProperty(true), { input in
            SignalProducer<Output, Error> { observer, disposable in
                transform(input).analysis(ifSuccess: {
                    sendNext(observer, $0)
                    sendCompleted(observer)
                }, ifFailure: {
                    sendError(observer, $0)
                })
            }
        })
    }
    
    var mEvents: Signal<Event<Output, Error>, NoError> {
        return events |> observeOn(UIScheduler())
    }
    var mValues: Signal<Output, NoError> {
        return values |> observeOn(UIScheduler())
    }
    var mErrors: Signal<Error, NoError> {
        return errors |> observeOn(UIScheduler())
    }
    var mExecuting: SignalProducer<Bool, NoError> {
        return executing.producer |> observeOn(UIScheduler())
    }
    var mEnabled: SignalProducer<Bool, NoError> {
        return enabled.producer |> observeOn(UIScheduler())
    }
}

// MARK: - Property Extensions

extension MutableProperty {
    convenience init(_ initialValue: T, @noescape _ block: () -> SignalProducer<T, ReactiveCocoa.NoError>) {
        self.init(initialValue)
        self <~ block()
    }
    
    convenience init(_ initialValue: T, @noescape _ block: () -> Signal<T, ReactiveCocoa.NoError>) {
        self.init(initialValue)
        self <~ block()
    }
}

extension PropertyOf {
    init(_ constantValue: T) {
        self.init(ConstantProperty(constantValue))
    }
    
    init(_ initialValue: T, _ producer: SignalProducer<T, ReactiveCocoa.NoError>) {
        self.init(MutableProperty(initialValue, { producer }))
    }
    
    init(_ initialValue: T, @noescape _ block: () -> SignalProducer<T, ReactiveCocoa.NoError>) {
        self.init(MutableProperty(initialValue, block))
    }
    
    init(_ initialValue: T, @noescape _ block: () -> Signal<T, ReactiveCocoa.NoError>) {
        self.init(MutableProperty(initialValue, block))
    }
}