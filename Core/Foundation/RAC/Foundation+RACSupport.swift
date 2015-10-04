//
//  Foundation+RACSupport.swift
//  S10
//
//  Created by Tony Xiao on 7/13/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension NSObject {

    public func listenForNotification(name: String, object: AnyObject? = nil) -> SignalProducer<NSNotification, NoError> {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.rac_addObserverForName(name, object: object)
            .takeUntil(rac_willDeallocSignal())
            .toSignalProducer()
            .flatMapError { _ in .empty }
            .map { $0 as! NSNotification }
    }
}
