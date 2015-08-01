//
//  PropertyExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public func |> <P1 : PropertyType, X>(property: P1, @noescape transform: P1 -> X) -> X {
    return transform(property)
}

// TODO: Add lifting support to properties
public func map<P : PropertyType, T, U where P.Value == T>(transform: T -> U) -> P -> PropertyOf<U> {
    return { property in
        return PropertyOf(transform(property.value)) {
            property.producer |> map { v in
                let retainSourceProperty = property // Force retain source property
                return transform(v)
            }
        }
    }
}


public func flatMap<P : PropertyType, P2 : PropertyType, T, U where P.Value == T, P2.Value == U>(transform: T -> P2) -> P -> PropertyOf<U> {
    return { property in
        return PropertyOf(transform(property.value).value) {
            property.producer |> flatMap(.Latest) { v in
                let retainSourceProperty = property // Force retain source property
                return SignalProducer<U, NoError> { sink, disposable in
                    let innerProperty = transform(v)
                    disposable.addDisposable(innerProperty.producer.start(sink))
                    disposable.addDisposable {
                        let retainedProperty = innerProperty // Force retain inner property
                    }
                }
            }
        }
    }
}

public func flatMap<P : PropertyType, P2 : PropertyType, T, U where P.Value == T?, P2.Value == U>(#nilValue: U, transform: T -> P2) -> P -> PropertyOf<U> {
    return { property in
        return PropertyOf(property.value.map { transform($0).value } ?? nilValue) {
            property.producer |> flatMap(.Latest) { v in
                let retainSourceProperty = property // Force retain source property
                return SignalProducer<U, NoError> { sink, disposable in
                    if let v = v {
                        let innerProperty = transform(v)
                        disposable.addDisposable(innerProperty.producer.start(sink))
                        disposable.addDisposable {
                            let retainedProperty = innerProperty // Force retain inner property
                        }
                    } else {
                        sendNext(sink, nilValue)
                        sendCompleted(sink)
                    }
                }
            }
        }
    }
}

public func flatMap<P : PropertyType, P2 : PropertyType, T, U where P.Value == T?, P2.Value == U?>(transform: T -> P2) -> P -> PropertyOf<U?> {
    return flatMap(nilValue: nil, transform)
}


/// `mutableProperty |> readonly` will render a read only version of any mutable property type
/// Readonly is essentially an identity function
public func readonly<P : MutablePropertyType, T where P.Value == T>(property: P) -> PropertyOf<T> {
    return PropertyOf(property)
}

public func mutable<P : PropertyType, T where P.Value == T>(property: P) -> MutableProperty<T> {
    return MutableProperty(property.value) {
        property.producer |> map { v in
            let retainSourceProperty = property // Force retain source property
            return v
        }
    }
}
