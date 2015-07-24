//
//  ReactiveExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

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

func |> <P1 : PropertyType, X>(property: P1, @noescape transform: P1 -> X) -> X {
    return transform(property)
}

func map<P : PropertyType, T, U where P.Value == T>(transform: T -> U) -> P -> PropertyOf<U> {
    return { property in
        return PropertyOf(transform(property.value)) {
            property.producer |> map { v in
                let retainSourceProperty = property // Force retain source property
                return transform(v)
            }
        }
    }
}

/// `mutableProperty |> readonly` will render a read only version of any mutable property type
/// Readonly is essentially an identity function
func readonly<P : MutablePropertyType, T where P.Value == T>(property: P) -> PropertyOf<T> {
    return PropertyOf(property)
}

func mutable<P : PropertyType, T where P.Value == T>(property: P) -> MutableProperty<T> {
    return MutableProperty(property.value) {
        property.producer |> map { v in
            let retainSourceProperty = property // Force retain source property
            return v
        }
    }
}

// Counter part to ReactiveCocoa's <~ operator which is sometimes inconvenient to use

infix operator ~> {
    associativity left
    precedence 93
}

func ~> <P: MutablePropertyType>(signal: Signal<P.Value, ReactiveCocoa.NoError>, property: P) -> Disposable {
    return property <~ signal
}

func ~> <P: MutablePropertyType>(producer: SignalProducer<P.Value, ReactiveCocoa.NoError>, property: P) -> Disposable {
    return property <~ producer
}

func ~> <Destination: MutablePropertyType, Source: PropertyType where Source.Value == Destination.Value>(sourceProperty: Source, destinationProperty: Destination) -> Disposable {
    return destinationProperty <~ sourceProperty
}
