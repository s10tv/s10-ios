//
//  FoundationExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

func between<T : Comparable>(minLimit: T, value: T, maxLimit: T) -> T {
    return max(minLimit, min(value, maxLimit))
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

    /**
    Deletes all the items in self that are equal to element.
    
    :param: element Element to remove
    */
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
