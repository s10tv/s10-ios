//
//  ConnectServicesViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct ConnectServicesViewModel {
    public enum Error : ErrorType {
        case NoServiceConnected
        
        public var alertTitle: String { return "" }
        public var alertBody: String { return "" }
        public var nsError: NSError { return NSError() }
    }
    
    public func finish() -> RACFuture<Void, Error> {
        let promise = RACPromise<(), Error>()
        return promise.future
    }
}