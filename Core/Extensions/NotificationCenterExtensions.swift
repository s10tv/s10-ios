//
//  NotificationCenter.swift
//  Taylr
//
//  Created by Tony Xiao on 4/8/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

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
            observers.map { self.center.removeObserver($0) }
        }
        
        func listen(name: String, object: AnyObject? = nil, block: (NSNotification) -> ()) {
            observers += center.addObserverForName(name, object: object, queue: queue) { note in
                block(note)
            }
        }
    }
    
    public func proxy() -> Proxy {
        return Proxy(center: self)
    }
}