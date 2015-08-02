//
//  ActionExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

// MARK: - Actions

extension UIControl {
    public func addAction<I, O, E: ErrorType>(action: Action<I, O, E>, forControlEvents events: UIControlEvents = .TouchUpInside) {
        addTarget(action.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: events)
        action.enabled.producer
            |> observeOn(UIScheduler())
            |> start(next: { [weak self] enabled in
                self?.enabled = enabled
            })
    }
}

// Extend the meaning of the <~ operator in RAC to stream events from UIControls into Action

public func <~ <I, O, E: ErrorType>(action: Action<I, O, E>, control: UIControl) {
    control.addAction(action)
}

// Piping value of Signal and SignalProducer into Action

public func <~ <I, O, E: ErrorType>(action: Action<I, O, E>, signal: Signal<I, NoError>) {
    signal.observe(next: {
        action.apply($0).start()
    })
}

public func <~ <I, O, E: ErrorType>(action: Action<I, O, E>, producer: SignalProducer<I, NoError>) {
    producer.start(next: {
        action.apply($0).start()
    })
}

