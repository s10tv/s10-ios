//
//  BondExtensions.swift
//  S10
//
//  Created by Tony Xiao on 6/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import Bond

public func unbindAll<U: Bondable>(bondables: U...) {
    for bondable in bondables {
        bondable.designatedBond.unbindAll()
    }
}

// MARK: - Dynamic Support

public extension NSObject {
    public func dynValue<T>(keyPath: String, _ defaultValue: T? = nil) -> Dynamic<T?> {
        return dynamicOptionalObservableFor(self, keyPath: keyPath, defaultValue: defaultValue)
    }
    public func dynValue<T>(keyPath: Printable, _ defaultValue: T? = nil) -> Dynamic<T?> {
        return dynValue(keyPath.description, defaultValue)
    }
}
