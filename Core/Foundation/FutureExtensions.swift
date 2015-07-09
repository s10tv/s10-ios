//
//  FutureExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import BrightFutures

func perform<T, E>(@noescape futureProducer: () -> Future<T, E>) -> Future<T, E> {
    return futureProducer()
}

// Add the concept of cancellation to Future & promises

private func executionContextForCurrentContext() -> ExecutionContext {
    return toContext(NSThread.isMainThread() ? Queue.main : Queue.global)
}

private let errCancelled = NSError(domain: "BrightFutures", code: NSUserCancelledError, userInfo: nil)

extension Future {
    typealias CancelCallback = () -> ()
    typealias ErrorCallback = E -> ()
    
    var isCancelled: Bool {
        return error?.nsError == errCancelled
    }
    
    var isError: Bool {
        return isFailure && !isCancelled
    }
    
    func onError(context c: ExecutionContext = executionContextForCurrentContext(), callback: ErrorCallback) {
        onFailure(context: c) { error in
            if error.nsError != errCancelled { callback(error) }
        }
    }
    
    func onCancel(context c: ExecutionContext = executionContextForCurrentContext(), callback: CancelCallback) {
        onFailure(context: c) { error in
            if error.nsError == errCancelled { callback() }
        }
    }
}

extension Promise {
    func error(error: E) {
        failure(error)
    }
    
    func cancel() {
        failure(errCancelled as! E)
    }
}
