//
//  RAC.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import ReactiveCocoa

// Stopgap solution, to be replaced in RAC 3.0
public struct Property {
    private let subject = RACReplaySubject(capacity: 1)
    public var signal: RACSignal { return subject }
    public var current: AnyObject? { return signal.first() }
    
    public init(_ initialValue: AnyObject? = nil) {
        _update(initialValue)
    }
    
    // Should only be called by producer of this property
    public func _update(value: AnyObject?) {
        subject.sendNext(value)
    }
}

// Avoid having to type cast all the time
extension RACSignal {
    public func subscribeNextAs<T>(nextClosure:(T) -> ()) -> RACDisposable {
        return self.subscribeNext { (next: AnyObject!) -> () in
            let nextAsT = next as! T
            nextClosure(nextAsT)
        }
    }
    
    public func subscribeErrorOrCompleted(block: (NSError?) -> ()) {
        subscribeError({ error in
            block(error)
        }, completed:{
            block(nil)
        })
    }
    
    // replayWithSubject has the advantage that signal would be subscribed to but
    // disposed as soon as subject is deallocated, rather than replay() in which signal is never
    // disposed of even if no one is listening to the subject anymore
    public func replayWithSubject() -> RACSignal {
        let subject = RACReplaySubject()
        subscribe(subject)
        return subject
    }
}

extension RACSubject {
    public func sendNextAndCompleted(value: AnyObject!) {
        sendNext(value)
        sendCompleted()
    }
}

extension NSObject {
    public func listenForNotification(name: String) -> RACSignal/*<NSNotification>*/ {
        return listenForNotification(name, object: nil)
    }
    
    public func listenForNotification(name: String, object: AnyObject?) -> RACSignal/*<NSNotification>*/ {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.rac_addObserverForName(name, object: object).takeUntil(rac_willDeallocSignal())
    }
    
    public func listenForNotification(name: String, selector: Selector, object: AnyObject? = nil) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: selector, name: name, object: object)
        rac_willDeallocSignal().subscribeCompleted { [weak self] in
            nc.removeObserver(self!)
        }
    }
    
    public func racObserve(keyPath: String) -> RACSignal {
        return self.rac_valuesForKeyPath(keyPath, observer: self)
    }
}

// Replaces the RACObserve macro
public func RACObserve(target: NSObject, keyPath: String) -> RACSignal  {
    return target.rac_valuesForKeyPath(keyPath, observer: target)
}


// a struct that replaces the RAC macro
public struct RAC {
    public var target : NSObject
    public var keyPath : String
    public var nilValue : AnyObject?
    
    public init(_ target: NSObject, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
        let sel = Selector("set\(keyPath.stringByCapitalizingFirstCharacter):")
        assert(target.respondsToSelector(sel), "RAC target must responds to selector \(sel)")
    }
    
    public func assignSignal(signal : RACSignal) {
        signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}

// RACObserve(obj, key) ~> RAC(obj, key)
infix operator ~> {}
public func ~> (signal: RACSignal, rac: RAC) {
    rac.assignSignal(signal)
}

// RAC(obj, key) <~ RACObserve(obj, key)
infix operator <~ {}
public func <~ (rac: RAC, signal: RACSignal) {
    rac.assignSignal(signal)
}
