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
    
    func each(@noescape block: Element -> ()) {
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
        for (_, current) in anotherSelf.enumerate() {
            if current as! U != element {
                self.append(current)
            }
        }
    }
    
    // Return first element matching block
    func match(criteria: Element -> Bool) -> Element? {
        return filter(criteria).first
    }
    
    func randomElement() -> Element? {
        if count == 0 { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    
    func minElement(scorer: ((Element) -> Float)) -> Element? {
        var minScore: Float?
        var minElement: Element?
        for element in self {
            let score = scorer(element)
            if minScore == nil || score < minScore! {
                minScore = score
                minElement = element
            }
        }
        return minElement
    }
    
    func elementAtIndex(index: Int?) -> Element? {
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
        return Dictionary<OutKey, OutValue>(self.map(transform))
    }
    
    func filter(includeElement: Element -> Bool) -> [Key: Value] {
        return Dictionary(self.filter(includeElement))
    }
}

extension Zip2Sequence {
    
    func map<U>(transform: (Sequence1.Generator.Element, Sequence2.Generator.Element) -> U) -> [U] {
        var results = [U]()
        for (e0, e1) in self {
            results.append(transform(e0, e1))
        }
        return results
    }
    
    func each(block: (Sequence1.Generator.Element, Sequence2.Generator.Element) -> ()) {
        for (e0, e1) in self {
            block(e0, e1)
        }
    }
    
}
