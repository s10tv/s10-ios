//
//  FoundationExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

infix operator ?> {}
func ?> <T, U>(optional: T?, transform: T -> U) -> U? {
    if let x = optional {
        return transform(x)
    }
    return nil
}

func between<T : Comparable>(minLimit: T, value: T, maxLimit: T) -> T {
    assert(minLimit <= maxLimit, "Minimum must be smaller than or equal to max")
    return max(minLimit, min(value, maxLimit))
}

func mapOptional<S : SequenceType, T>(source: S, transform: S.Generator.Element -> T?) -> [T] {
    return map(source) { transform($0) }.filter { $0 != nil }.map { $0! }
}

// Floats
extension Int {
    var f: CGFloat { return CGFloat(self) }
}

extension Float {
    var f: CGFloat { return CGFloat(self) }
}

extension Double {
    var f: CGFloat { return CGFloat(self) }
}

// Core Graphics

extension CGPoint {
    func distanceTo(point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
    func asVector() -> CGVector {
        return CGVector(dx: x, dy: y)
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func * (point: CGPoint, multiplier: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * multiplier, y: point.y * multiplier)
}

func + (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

func * (vector: CGVector, multiplier: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * multiplier, dy: vector.dy * multiplier)
}

// Foundation Types

extension String {
    
    var stringByCapitalizingFirstCharacter : String {
        let firstChar = substringToIndex(1)
        let rest = substringFromIndex(1)
        return "\(firstChar.uppercaseString)\(rest)"
    }
    
    // Courtesy of http://stackoverflow.com/questions/24029163/finding-index-of-character-in-swift-string
    
    // MARK: - sub String
    func substringToIndex(index:Int) -> String {
        return self.substringToIndex(advance(self.startIndex, index))
    }
    func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    func substringWithRange(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self.substringWithRange(start..<end)
    }
    
    subscript(index:Int) -> Character {
        return self[advance(self.startIndex, index)]
    }
    subscript(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }
    
    // MARK: - replace
    func replaceCharactersInRange(range:Range<Int>, withString: String!) -> String {
        var result:NSMutableString = NSMutableString(string: self)
        result.replaceCharactersInRange(NSRange(range), withString: withString)
        return result
    }
}

extension Array {

    func mapOptional<U>(transform: T -> U?) -> [U] {
        return Ketch.mapOptional(self, transform)
    }
    
    // Deletes all the items in self that are equal to element.
    mutating func remove <U: Equatable> (element: U) {
        let anotherSelf = self
        removeAll(keepCapacity: true)
        
        for (index, current) in enumerate(anotherSelf) {
            if current as U != element {
                self.append(current)
            }
        }
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

extension NSURL {
    convenience init!(_ urlString: String) {
        self.init(string: urlString)
    }
}

extension NSData {
    func hexString() -> NSString {
        var str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
}

extension NSAttributedString {
    func replace(#text: String) -> NSAttributedString {
        let attrString = mutableCopy() as NSMutableAttributedString
        attrString.mutableString.setString(text)
        return attrString
    }
    
    func replace(#font: UIFont, kern: CGFloat) -> NSAttributedString {
        let attrString = mutableCopy() as NSMutableAttributedString
        let range = NSMakeRange(0, attrString.length)
        attrString.addAttribute(NSFontAttributeName,
            value:font, range: range)
        attrString.addAttribute(NSKernAttributeName,
            value:kern, range: range)
        return attrString
    }
}