//
//  ArrayProperty.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public enum ArrayOperation {
    case Insert(Int)
    case Delete(Int)
    case Update(Int)
    case Batch([ArrayOperation])
    case Reset
}

public protocol ArrayPropertyType {
    typealias ElementType
    var array: [ElementType] { get }
    subscript(index: Int) -> ElementType { get }
    var changes: Signal<ArrayOperation, NoError> { get }
}

extension ArrayPropertyType {
    var count: Int { return array.count }
}

extension ArrayPropertyType where Self : AnyObject {
    var count: PropertyOf<Int> {
        let prop = MutableProperty(array.count)
        prop <~ changes.map { [weak self] _ in self?.array.count ?? 0 }
        return prop.readonly()
    }
    var producer: SignalProducer<[ElementType], NoError> {
        return SignalProducer { [weak self] observer, disposable in
            if let this = self {
                sendNext(observer, this.array)
                disposable += this.changes.observe(Event.sink(next: { [weak self] _ in
                    if let this = self { sendNext(observer, this.array) }
                }, completed: {
                    sendCompleted(observer)
                }))
            } else {
                sendInterrupted(observer)
            }
        }
    }
}

public class ArrayProperty<T> : ArrayPropertyType {
    private let changesSink: Event<ArrayOperation, NoError>.Sink
    private var updatesDisposable: Disposable?
    public typealias ElementType = T
    public var array: [T] {
        didSet { sendNext(changesSink, .Reset) }
    }
    public subscript(index: Int) -> T {
        return array[index]
    }
    public let changes: Signal<ArrayOperation, NoError>

    public init(_ array: [T], updates: SignalProducer<[T], NoError>? = nil) {
        self.array = array
        (changes, changesSink) = Signal<ArrayOperation, NoError>.pipe()
        updatesDisposable = updates?.startWithNext { [weak self] array in
            self?.array = array
        }
    }
    
    deinit {
        sendCompleted(changesSink)
        updatesDisposable?.dispose()
    }
}

// Queue Implementation

extension ArrayProperty {
    public func dequeue() -> T? {
        if let first = array.first {
            array.removeAtIndex(0)
            // BIG TODO: array.removeAtindex actually triggers .Reset. Fix me
//            sendNext(changesSink, .Delete(0))
            return first
        }
        return nil
    }
    
    public func enqueue(element: T) {
        array.append(element)
        // BIG TODO: array.append actually triggers .Reset
//        sendNext(changesSink, .Insert(array.count-1))
    }
}

extension PropertyType where Value : CollectionType {
    public func array() -> ArrayProperty<Value.Generator.Element> {
        let array = ArrayProperty<Value.Generator.Element>([])
        producer.startWithNext { [weak array] value in
            _ = self // Intentionally strongly retain property
            array?.array = Array(value)
        }
        return array
    }
}

