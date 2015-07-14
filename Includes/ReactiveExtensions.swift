//
//  ReactiveExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import BrightFutures
import Bond
import Box

// MARK: - Reactive Extensions

extension MutableProperty {
    convenience init(_ initialValue: T, @noescape _ block: () -> SignalProducer<T, ReactiveCocoa.NoError>) {
        self.init(initialValue)
        self <~ block()
    }
}

extension PropertyOf {
    init(_ initialValue: T, @noescape _ block: () -> SignalProducer<T, ReactiveCocoa.NoError>) {
        self.init(MutableProperty(initialValue, block))
    }
}

// Cocoa KVO support

extension DynamicProperty {
    func object<T>(type: T.Type) -> KVCObjectProperty<T> {
        return KVCObjectProperty(backing: self, type: type)
    }
    func primitive<T>(type: T.Type) -> KVCPrimitiveProperty<T> {
        return KVCPrimitiveProperty(backing: self, type: type)
    }
}

final class KVCObjectProperty<T> : MutablePropertyType {
    typealias Value = T?
    
    private let backing: DynamicProperty
    
    var value: T? {
        get { return backing.value as? T }
        set { backing.value = newValue as? AnyObject }
    }
    var producer: SignalProducer<T?, ReactiveCocoa.NoError> {
        return backing.producer |> map { $0 as? T }
    }
    var readonly: PropertyOf<T?> {
        return PropertyOf(self)
    }
    
    init(backing: DynamicProperty, type: T.Type) {
        self.backing = backing
    }
    
    convenience init(object: NSObject?, keyPath: String, type: T.Type) {
        self.init(backing: DynamicProperty(object: object, keyPath: keyPath), type: type)
    }
}

final class KVCPrimitiveProperty<T> : MutablePropertyType {
    typealias Value = T
    
    private let backing: DynamicProperty
    
    var value: T {
        get { return backing.value as! T }
        set { backing.value = newValue as? AnyObject }
    }
    var producer: SignalProducer<T, ReactiveCocoa.NoError> {
        return backing.producer |> map { $0 as! T }
    }
    var readonly: PropertyOf<T> {
        return PropertyOf(self)
    }
    
    init(backing: DynamicProperty, type: T.Type) {
        self.backing = backing
    }
    
    convenience init(object: NSObject?, keyPath: String, type: T.Type) {
        self.init(backing: DynamicProperty(object: object, keyPath: keyPath), type: type)
    }
}

extension NSObject {
    func dyn(keyPath: String) -> DynamicProperty {
        return DynamicProperty(object: self, keyPath: keyPath)
    }
    
    func kvcObject<T>(keyPath: String, type: T.Type) -> KVCObjectProperty<T> {
        return KVCObjectProperty(object: self, keyPath: keyPath, type: type)
    }
    
    func kvcPrimitive<T>(keyPath: String, type: T.Type) -> KVCObjectProperty<T> {
        return KVCObjectProperty(object: self, keyPath: keyPath, type: type)
    }
    
    
    func propertyOf<T>(keyPath: String, type: T.Type) -> PropertyOf<T?> {
        return PropertyOf(kvcObject(keyPath, type: type))
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

// MARK: - ReactiveCocoa + SwiftBonds

extension PropertyOf {
    var dyn: Dynamic<T> {
        let dyn = InternalDynamic<T>(value)
        dyn.retain(Box(self))
        producer.start(next: { value in
            dyn.value = value
        })
        return dyn
    }
}

extension MutableProperty {
    var dyn: Dynamic<T> {
        let dyn = InternalDynamic<T>(value)
        dyn.retain(self)
        producer.start(next: { value in
            dyn.value = value
        })
        return dyn
    }
}

// Bind and fire

func ->> <T, U: Bondable where U.BondType == T>(left: PropertyOf<T>, right: U) {
    left.dyn ->> right.designatedBond
}

func ->> <T, U: Bondable where U.BondType == T>(left: MutableProperty<T>, right: U) {
    left.dyn ->> right.designatedBond
}

// Bind only

func ->| <T, U: Bondable where U.BondType == T>(left: PropertyOf<T>, right: U) {
    left.dyn ->| right.designatedBond
}

func ->| <T, U: Bondable where U.BondType == T>(left: MutableProperty<T>, right: U) {
    left.dyn ->| right.designatedBond
}

// MARK: ReactiveCocoa + BrightFutures

let errSignalInterrupted = NSError(domain: "ReactiveCocoa", code: NSUserCancelledError, userInfo: nil)

extension SignalProducer {
    func future() -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        var value: T?
        start(error: {
            promise.failure($0.nsError)
            }, interrupted: {
                promise.failure(errSignalInterrupted)
            }, completed: {
                if let value = value {
                    promise.success(value)
                } else {
                    promise.success(() as! T)
                }
            }, next: {
                assert(value == nil, "future should only have 1 value")
                value = $0
        })
        return promise.future
    }
}

extension Future {
    func signalProducer() -> SignalProducer<T, NSError> {
        // TODO: Make more sense of memory management
        return SignalProducer { sink, disposable in
            // Local variable to work around swiftc compilation bug
            // http://www.markcornelisse.nl/swift/swift-invalid-linkage-type-for-function-declaration/
            let successBlock: T -> () = {
                sendNext(sink, $0)
                sendCompleted(sink)
            }
            self.onSuccess(callback: successBlock).onFailure {
                sendError(sink, $0.nsError)
            }
        }
    }
}
