//
//  FoundationExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import UIKit

// Foundation Types

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


extension NSNotificationCenter {
    public class Proxy {
        let queue : NSOperationQueue
        let center : NSNotificationCenter
        var observers : [NSObjectProtocol] = []
        
        init(center: NSNotificationCenter, queue: NSOperationQueue = NSOperationQueue.mainQueue()) {
            self.center = center
            self.queue = queue
        }
        
        deinit {
            for o in observers { center.removeObserver(o) }
        }
        
        public func listen(name: String, object: AnyObject? = nil, block: (NSNotification) -> ()) -> Proxy {
            observers += center.addObserverForName(name, object: object, queue: queue) { note in
                block(note)
            }
            return self
        }
    }
    
    public func proxy() -> Proxy {
        return Proxy(center: self)
    }
}

// NSDate type

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}

