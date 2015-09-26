//
//  FoundationExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

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
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
}

extension NSAttributedString {
    public func replace(text text: String) -> NSAttributedString {
        let attrString = mutableCopy() as! NSMutableAttributedString
        attrString.mutableString.setString(text)
        return attrString
    }
    
    public func replace(font font: UIFont, kern: CGFloat? = nil, color: UIColor? = nil) -> NSAttributedString {
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

