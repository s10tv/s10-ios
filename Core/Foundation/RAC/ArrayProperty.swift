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

extension ArrayPropertyType where Self : AnyObject {
    var count: PropertyOf<Int> {
        let prop = MutableProperty(array.count)
        prop <~ changes.map { [weak self] _ in self?.array.count ?? 0 }
        return prop.readonly()
    }
}

public class ArrayProperty<T> : ArrayPropertyType {
    private let changesSink: Event<ArrayOperation, NoError>.Sink
    public typealias ElementType = T
    public var array: [T] {
        didSet { sendNext(changesSink, .Reset) }
    }
    public subscript(index: Int) -> T {
        return array[index]
    }
    public let changes: Signal<ArrayOperation, NoError>

    public init(_ array: [T]) {
        self.array = array
        (changes, changesSink) = Signal<ArrayOperation, NoError>.pipe()
    }
    
    deinit {
        sendCompleted(changesSink)
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

