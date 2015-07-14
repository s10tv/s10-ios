//
//  ReactiveExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

// MARK: - Typed KVO support

final class DynamicOptionalTypedProperty<T> : MutablePropertyType {
    typealias Value = T?
    
    private let backing: DynamicProperty
    
    var value: T? {
        get { return backing.value as? T }
        set { backing.value = newValue as? AnyObject }
    }
    var producer: SignalProducer<T?, ReactiveCocoa.NoError> {
        return backing.producer |> map { $0 as? T }
    }
    
    init(backing: DynamicProperty, type: T.Type) {
        self.backing = backing
    }
    
    convenience init(object: NSObject?, keyPath: String, type: T.Type) {
        self.init(backing: DynamicProperty(object: object, keyPath: keyPath), type: type)
    }
}

final class DynamicForceTypedProperty<T> : MutablePropertyType {
    typealias Value = T
    
    private let backing: DynamicProperty
    
    var value: T {
        get { return backing.value as! T }
        set { backing.value = newValue as? AnyObject }
    }
    
    var producer: SignalProducer<T, ReactiveCocoa.NoError> {
        return backing.producer |> map { $0 as! T }
    }
    
    init(backing: DynamicProperty, type: T.Type) {
        self.backing = backing
    }
    
    convenience init(object: NSObject?, keyPath: String, type: T.Type) {
        self.init(backing: DynamicProperty(object: object, keyPath: keyPath), type: type)
    }
}

extension DynamicProperty {
    func optional<T>(type: T.Type) -> DynamicOptionalTypedProperty<T> {
        return DynamicOptionalTypedProperty(backing: self, type: type)
    }
    func force<T>(type: T.Type) -> DynamicForceTypedProperty<T> {
        return DynamicForceTypedProperty(backing: self, type: type)
    }
}

extension NSObject {
    func dyn(keyPath: String) -> DynamicProperty {
        return DynamicProperty(object: self, keyPath: keyPath)
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
    init(_ initialValue: T, @noescape _ block: () -> SignalProducer<T, ReactiveCocoa.NoError>) {
        self.init(MutableProperty(initialValue, block))
    }
    
    init(_ initialValue: T, @noescape _ block: () -> Signal<T, ReactiveCocoa.NoError>) {
        self.init(MutableProperty(initialValue, block))
    }
}

func |> <P: PropertyType, T, U where P.Value == T>(property: P, transform: T -> U) -> PropertyOf<U> {
    return PropertyOf(transform(property.value)) {
        property.producer |> map(transform)
    }
}

func |> <P1: PropertyType, P2: PropertyType where P1.Value == P2.Value>(property: P1, transform: P1 -> P2) -> P2 {
    return transform(property)
}

func readonly<P: PropertyType, T where P.Value == T>(property: P) -> PropertyOf<T> {
    return PropertyOf(property)
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

// MARK: - RAC2 Extensions

// Avoid having to type cast all the time
extension RACSignal {
    func subscribeNextAs<T>(nextClosure:(T) -> ()) -> RACDisposable {
        return self.subscribeNext { (next: AnyObject!) -> () in
            let nextAsT = next as! T
            nextClosure(nextAsT)
        }
    }
    
    func subscribeErrorOrCompleted(block: (NSError?) -> ()) {
        subscribeError({ error in
            block(error)
            }, completed:{
                block(nil)
        })
    }
    
    // replayWithSubject has the advantage that signal would be subscribed to but
    // disposed as soon as subject is deallocated, rather than replay() in which signal is never
    // disposed of even if no one is listening to the subject anymore
    public func replayWithSubject() -> RACSignal {
        let subject = RACReplaySubject()
        subscribe(subject)
        return subject
    }
}

extension RACSubject {
    func sendNextAndCompleted(value: AnyObject!) {
        sendNext(value)
        sendCompleted()
    }
}

extension NSObject {
    // TODO: Convert these to RAC 3 with swift
    func listenForNotification(name: String) -> RACSignal/*<NSNotification>*/ {
        return listenForNotification(name, object: nil)
    }
    
    func listenForNotification(name: String, object: AnyObject?) -> RACSignal/*<NSNotification>*/ {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.rac_addObserverForName(name, object: object).takeUntil(rac_willDeallocSignal())
    }
    
    func listenForNotification(name: String, selector: Selector, object: AnyObject? = nil) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: selector, name: name, object: object)
        rac_willDeallocSignal().subscribeCompleted { [weak self] in
            nc.removeObserver(self!)
        }
    }
    
    func racObserve(keyPath: String) -> RACSignal {
        return self.rac_valuesForKeyPath(keyPath, observer: self)
    }
}
