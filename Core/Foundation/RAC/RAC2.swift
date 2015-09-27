//
//  RAC2.swift
//  S10
//
//  Created by Tony Xiao on 7/13/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

// Legacy code for ReactiveCocoa 2, need to be removed when time is right

// MARK: - ReactiveCocoa 2.x

// Avoid having to type cast all the time
extension RACSignal {
    func subscribeNextAs<T>(nextClosure:(T) -> ()) -> RACDisposable {
        return self.subscribeNext { (next: AnyObject!) -> () in
            let nextAsT = next as! T
            nextClosure(nextAsT)
        }
    }
    
    func subscribeErrorOrCompleted(block: (NSError?) -> ()) {
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
    func sendNextAndCompleted(value: AnyObject!) {
        self.sendNext(value)
        self.sendCompleted()
    }
}

extension NSObject {

    func listenForNotification(name: String, object: AnyObject? = nil) -> SignalProducer<NSNotification, NoError> {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.rac_addObserverForName(name, object: object)
            .takeUntil(rac_willDeallocSignal())
            .toSignalProducer()
            .flatMapError { _ in .empty }
            .map { $0 as! NSNotification }
    }
    
    // TODO: Convert these to RAC 3 with swift
    func listenForNotification(name: String) -> RACSignal/*<NSNotification>*/ {
        return listenForNotification(name, object: nil)
    }
    
    func listenForNotification(name: String, object: AnyObject?) -> RACSignal/*<NSNotification>*/ {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.rac_addObserverForName(name, object: object).takeUntil(rac_willDeallocSignal())
    }
    
    func listenForNotification(name: String, selector: Selector, object: AnyObject? = nil) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: selector, name: name, object: object)
        rac_willDeallocSignal().subscribeCompleted { [weak self] in
            nc.removeObserver(self!)
        }
    }
    
    func racObserve(keyPath: String) -> RACSignal {
        return self.rac_valuesForKeyPath(keyPath, observer: self)
    }
}
