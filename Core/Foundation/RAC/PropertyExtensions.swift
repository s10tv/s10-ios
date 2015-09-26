//
//  PropertyExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

// TODO: Add lifting support to properties
//public func |> <P1 : PropertyType, X>(property: P1, @noescape transform: P1 -> X) -> X {
//    return transform(property)
//}

// MARK: - Property Type Extensions

extension PropertyType {
    public func map<U>(transform: Value -> U) -> PropertyOf<U> {
        return PropertyOf(transform(self.value)) {
            self.producer.map { v in
                _ = self // Force retain source property
                return transform(v)
            }
        }
    }
    
    public func flatMap<P2 : PropertyType, U where P2.Value == U>(transform: Value -> P2) -> PropertyOf<U> {
        return PropertyOf(transform(self.value).value) {
            self.producer.flatMap(.Latest) { v in
                _ = self // Force retain source property
                return SignalProducer<U, NoError> { sink, disposable in
                    let innerProperty = transform(v)
                    disposable.addDisposable(innerProperty.producer.start(sink))
                    disposable.addDisposable {
                        _ = innerProperty // Force retain inner property
                    }
                }
            }
        }
    }
    
    public func mutable() -> MutableProperty<Value> {
        return MutableProperty(self.value) {
            self.producer.map { v in
                _ = self // Force retain source property
                return v
            }
        }
    }
}

extension PropertyType where Value: OptionalType {
    public func flatMap<P2 : PropertyType,  U where P2.Value == U>(nilValue nilValue: U, transform: Value.T -> P2) -> PropertyOf<U> {
        return PropertyOf(self.value.optional.map { transform($0).value } ?? nilValue) {
            self.producer.flatMap(.Latest) { v in
                _ = self // Force retain source property
                return SignalProducer<U, NoError> { sink, disposable in
                    if let v = v.optional {
                        let innerProperty = transform(v)
                        disposable.addDisposable(innerProperty.producer.start(sink))
                        disposable.addDisposable {
                            _ = innerProperty // Force retain inner property
                        }
                    } else {
                        sendNext(sink, nilValue)
                        sendCompleted(sink)
                    }
                }
            }
        }
    }
    
    public func flatMap<P2 : PropertyType, U where P2.Value == U?>(transform: Value.T -> P2) -> PropertyOf<U?> {
        return flatMap(nilValue: nil, transform: transform)
    }
}

extension MutablePropertyType {
    /// `readonly` will render a read only version of any mutable property type
    /// Readonly is essentially an identity function
    public func readonly() -> PropertyOf<Value> {
        return PropertyOf(self)
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