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

public struct ConstantArray<T> : ArrayPropertyType {
    public typealias ElementType = T
    public let array: [T]
    public let changes: Signal<ArrayOperation, NoError>
    public subscript(index: Int) -> T {
        return array[index]
    }

    public init(array: [T]) {
        self.array = array
        self.changes = Signal.never
    }
}