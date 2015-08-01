//
//  RACGenericExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
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