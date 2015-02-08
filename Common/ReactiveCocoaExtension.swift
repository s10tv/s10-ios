//
//  RAC.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import ReactiveCocoa

// Avoid having to type cast all the time
extension RACSignal {
    func subscribeNextAs<T>(nextClosure:(T) -> ()) -> () {
        self.subscribeNext { (next: AnyObject!) -> () in
            let nextAsT = next as T
            nextClosure(nextAsT)
        }
    }
}

extension NSObject {
    func listenForNotification(name: String) -> RACSignal/*NSNotification*/ {
        return listenForNotification(name, object: nil)
    }
    
    func listenForNotification(name: String, object: AnyObject?) -> RACSignal/*NSNotification*/ {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.rac_addObserverForName(name, object: object).takeUntil(rac_willDeallocSignal())
    }
}

// Replaces the RACObserve macro
func RACObserve(target: NSObject, keyPath: String) -> RACSignal  {
    return target.rac_valuesForKeyPath(keyPath, observer: target)
}

// a struct that replaces the RAC macro
struct RAC  {
    var target : NSObject
    var keyPath : String
    var nilValue : AnyObject?
    
    init(_ target: NSObject, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    func assignSignal(signal : RACSignal) {
        signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}

// RACObserve(obj, key) ~> RAC(obj, key)
infix operator ~> {}
func ~> (signal: RACSignal, rac: RAC) {
    rac.assignSignal(signal)
}

// RAC(obj, key) <~ RACObserve(obj, key)
infix operator <~ {}
func <~ (rac: RAC, signal: RACSignal) {
    rac.assignSignal(signal)
}
