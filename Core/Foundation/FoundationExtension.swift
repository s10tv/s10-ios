//
//  FoundationExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

public func between<T : Comparable>(minLimit: T, value: T, maxLimit: T) -> T {
    assert(minLimit <= maxLimit, "Minimum must be smaller than or equal to max")
    return max(minLimit, min(value, maxLimit))
}

public func mapOptional<S : SequenceType, T>(source: S, transform: S.Generator.Element -> T?) -> [T] {
    return map(source) { transform($0) }.filter { $0 != nil }.map { $0! }
}

func find<C: CollectionType>(source: C, match: C.Generator.Element -> Bool) -> C.Index? {
    for idx in indices(source) {
        if match(source[idx]) { return idx }
    }
    return nil
}

// Floats
extension Int {
    public var f: CGFloat { return CGFloat(self) }
}

extension Float {
    public var f: CGFloat { return CGFloat(self) }
}

extension Double {
    public var f: CGFloat { return CGFloat(self) }
}

// Foundation Types

extension String {
    public var length: Int { return count(self) }
    
    public var stringByCapitalizingFirstCharacter : String {
        let firstChar = substringToIndex(1)
        let rest = substringFromIndex(1)
        return "\(firstChar.uppercaseString)\(rest)"
    }
    
    // Courtesy of http://stackoverflow.com/questions/24029163/finding-index-of-character-in-swift-string
    
    // MARK: - sub String
    public func substringToIndex(index:Int) -> String {
        return self.substringToIndex(advance(self.startIndex, index))
    }
    public func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    public func substringWithRange(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self.substringWithRange(start..<end)
    }
    
    public subscript(index:Int) -> Character {
        return self[advance(self.startIndex, index)]
    }
    public subscript(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }
    
    // MARK: - replace
    public func replaceCharactersInRange(range:Range<Int>, withString: String!) -> String {
        var result:NSMutableString = NSMutableString(string: self)
        result.replaceCharactersInRange(NSRange(range), withString: withString)
        return result as String
    }
    
    public func nonBlank() -> String? {
        let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return trimmed.length > 0 ? trimmed : nil
    }
}

public func += <T>(inout array: [T], element: T) {
    array.append(element)
}

extension NSURL {
    public convenience init!(_ urlString: String) {
        self.init(string: urlString)
    }
    public class func fromString(str: String?) -> NSURL? {
        return (str != nil) ? NSURL(str!) : nil
    }
}

extension NSData {
    public func hexString() -> NSString {
        var str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
}

extension NSAttributedString {
    public func replace(#text: String) -> NSAttributedString {
        let attrString = mutableCopy() as! NSMutableAttributedString
        attrString.mutableString.setString(text)
        return attrString
    }
    
    public func replace(#font: UIFont, kern: CGFloat? = nil, color: UIColor? = nil) -> NSAttributedString {
        let attrString = mutableCopy() as! NSMutableAttributedString
        let range = NSMakeRange(0, attrString.length)
        attrString.addAttribute(NSFontAttributeName, value:font, range: range)
        if let kern = kern {
            attrString.addAttribute(NSKernAttributeName, value:kern, range: range)
        }
        if let color = color {
            attrString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        }
        return attrString
    }
    
    public func replace(configure: (NSMutableAttributedString, NSRange) -> ()) -> NSAttributedString {
        let attrString = mutableCopy() as! NSMutableAttributedString
        let range = NSMakeRange(0, attrString.length)
        configure(attrString, range)
        return attrString
    }
}

// NSDate type

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}

