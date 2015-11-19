//
//  SwiftExtension.swift
//  S10
//
//  Created by Tony Xiao on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

public func += <T>(inout array: [T], element: T) {
    array.append(element)
}

extension String {
    
    public var length: Int { return characters.count }
    
    public var stringByCapitalizingFirstCharacter : String {
        let firstChar = substringToIndex(1)
        let rest = substringFromIndex(1)
        return "\(firstChar.uppercaseString)\(rest)"
    }
    
    // Courtesy of http://stackoverflow.com/questions/24029163/finding-index-of-character-in-swift-string
    
    // MARK: - sub String
    public func substringToIndex(index:Int) -> String {
        return self.substringToIndex(self.startIndex.advancedBy(index))
    }
    public func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    public func substringWithRange(range:Range<Int>) -> String {
        let start = self.startIndex.advancedBy(range.startIndex)
        let end = self.startIndex.advancedBy(range.endIndex)
        return self.substringWithRange(start..<end)
    }
    
    public subscript(index:Int) -> Character {
        return self[self.startIndex.advancedBy(index)]
    }
    public subscript(range:Range<Int>) -> String {
        let start = self.startIndex.advancedBy(range.startIndex)
        let end = self.startIndex.advancedBy(range.endIndex)
        return self[start..<end]
    }
    
    // MARK: - replace
    public func replaceCharactersInRange(range:Range<Int>, withString: String!) -> String {
        let result:NSMutableString = NSMutableString(string: self)
        result.replaceCharactersInRange(NSRange(range), withString: withString)
        return result as String
    }
    
    public func nonBlank() -> String? {
        let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return trimmed.isEmpty ? nil : trimmed
    }
}

public extension Array {
    
    func each(@noescape block: Element -> ()) {
        for element in self {
            block(element)
        }
    }
    
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
