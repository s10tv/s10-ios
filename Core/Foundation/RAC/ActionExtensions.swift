//
//  ActionExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

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
        return events.observeOn(UIScheduler())
    }
    var mValues: Signal<Output, NoError> {
        return values.observeOn(UIScheduler())
    }
    var mErrors: Signal<Error, NoError> {
        return errors.observeOn(UIScheduler())
    }
    var mExecuting: SignalProducer<Bool, NoError> {
        return executing.producer.observeOn(UIScheduler())
    }
    var mEnabled: SignalProducer<Bool, NoError> {
        return enabled.producer.observeOn(UIScheduler())
    }
}

// MARK: - Actions

extension UIControl {
    public func addAction<I, O, E: ErrorType>(action: Action<I, O, E>, forControlEvents events: UIControlEvents = .TouchUpInside,
        @noescape configure: (Signal<O, NoError>, Signal<E, NoError>, PropertyOf<Bool>) -> ()) {
        addTarget(action.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: events)
        action.enabled.producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self] enabled in
                self?.enabled = enabled
            }
        configure(action.mValues, action.mErrors, action.executing)
    }
}

// Extend the meaning of the <~ operator in RAC to stream events from UIControls into Action

//public func <~ <I, O, E: ErrorType>(action: Action<I, O, E>, control: UIControl) {
//    control.addAction(action) { _, _, _ in }
//}

// Piping value of Signal and SignalProducer into Action

public func <~ <I, O, E: ErrorType>(action: Action<I, O, E>, signal: Signal<I, NoError>) -> Disposable {
    let disposable = CompositeDisposable()
    disposable += signal.observeNext {
        disposable += action.apply($0).start()
    }
    return disposable
}

public func <~ <I, O, E: ErrorType>(action: Action<I, O, E>, producer: SignalProducer<I, NoError>) -> Disposable {
    let disposable = CompositeDisposable()
    disposable += producer.startWithNext {
        disposable += action.apply($0).start()
    }
    return disposable
}

