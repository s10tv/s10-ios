//
//  DynamicProperties.swift
//  S10
//
//  Created by Tony Xiao on 7/23/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

// MARK: - Typed KVO support

final public class DynamicOptionalTypedProperty<T> : MutablePropertyType {
    public typealias Value = T?
    
    private let backing: DynamicProperty
    
    public var value: T? {
        get { return backing.value as? T }
        set { backing.value = newValue as? AnyObject }
    }
    public var producer: SignalProducer<T?, ReactiveCocoa.NoError> {
        return backing.producer.map { $0 as? T }
    }
    
    public init(backing: DynamicProperty, type: T.Type) {
        self.backing = backing
    }
    
    public convenience init(object: NSObject?, keyPath: String, type: T.Type) {
        self.init(backing: DynamicProperty(object: object, keyPath: keyPath), type: type)
    }
}

final public class DynamicForceTypedProperty<T> : MutablePropertyType {
    public typealias Value = T
    
    private let backing: DynamicProperty
    
    public var value: T {
        get { return backing.value as! T }
        set { backing.value = newValue as? AnyObject }
    }
    
    public var producer: SignalProducer<T, ReactiveCocoa.NoError> {
        return backing.producer.map { $0 as! T }
    }
    
    public init(backing: DynamicProperty, type: T.Type) {
        self.backing = backing
    }
    
    public convenience init(object: NSObject?, keyPath: String, type: T.Type) {
        self.init(backing: DynamicProperty(object: object, keyPath: keyPath), type: type)
    }
}

extension DynamicProperty {
    public func optional<T>(type: T.Type) -> DynamicOptionalTypedProperty<T> {
        return DynamicOptionalTypedProperty(backing: self, type: type)
    }
    public func force<T>(type: T.Type) -> DynamicForceTypedProperty<T> {
        return DynamicForceTypedProperty(backing: self, type: type)
    }
}

extension NSObject {
    public func dyn(keyPath: String) -> DynamicProperty {
        return DynamicProperty(object: self, keyPath: keyPath)
    }
}
