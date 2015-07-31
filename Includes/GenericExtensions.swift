//
//  GenericExtensions.swift
//  S10
//
//  Created by Tony Xiao on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

// Generic extensions cannot be included as part of Framework as of latest swift version
// yet, therefore this file should be included as part of every target that wants these extensions
// Files in this catagory should not have any other external dependencies in addition to Swift runtime
// itself

import Foundation

extension Array {
    
    func each(@noescape block: T -> ()) {
        for element in self {
            block(element)
        }
    }
    
//    func mapOptional<U>(transform: T -> U?) -> [U] {
//        return Core.mapOptional(self, transform)
//    }
    
    // Deletes all the items in self that are equal to element.
    mutating func remove <U: Equatable> (element: U) {
        let anotherSelf = self
        removeAll(keepCapacity: true)
        
        for (index, current) in enumerate(anotherSelf) {
            if current as! U != element {
                self.append(current)
            }
        }
    }
    
    // Return first element matching block
    func match(criteria: T -> Bool) -> T? {
        return filter(criteria).first
    }
    
    func randomElement() -> T? {
        if count == 0 { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    
    func minElement(scorer: ((T) -> Float)) -> T? {
        var minScore: Float?
        var minElement: T?
        for element in self {
            let score = scorer(element)
            if minScore == nil || score < minScore! {
                minScore = score
                minElement = element
            }
        }
        return minElement
    }
    
    func elementAtIndex(index: Int?) -> T? {
        if let i = index {
            return (i >= 0 && i < count) ? self[i] : nil
        }
        return nil
    }
}

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    func map<OutKey: Hashable, OutValue>(transform: Element -> (OutKey, OutValue)) -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(Swift.map(self, transform))
    }
    
    func filter(includeElement: Element -> Bool) -> [Key: Value] {
        return Dictionary(Swift.filter(self, includeElement))
    }
}

extension Zip2 {
    
    func map<U>(transform: (S0.Generator.Element, S1.Generator.Element) -> U) -> [U] {
        var results = [U]()
        for (e0, e1) in self {
            results.append(transform(e0, e1))
        }
        return results
    }
    
    func each(block: (S0.Generator.Element, S1.Generator.Element) -> ()) {
        for (e0, e1) in self {
            block(e0, e1)
        }
    }
    
}
