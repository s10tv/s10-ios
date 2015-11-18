//
//  AsyncOperation.swift
//  S10
//
//  Created by Tony Xiao on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

extension NSError {
    public var isCancelled: Bool {
        return self.code == NSUserCancelledError
    }
}

extension NSOperationQueue {
    public func addAsyncOperation(@noescape opProducer: () -> AsyncOperation) -> Future<(), NSError> {
        let op = opProducer()
        addOperation(op)
        return op.future
    }
    
    public func addAsyncOperation(op: AsyncOperation) -> Future<(), NSError> {
        return addAsyncOperation { op }
    }
}

public class AsyncOperation : NSOperation {

    // MARK: - Types
    
    public enum State {
        case Ready, Executing, Finished
        func keyPath() -> String {
            switch self {
            case Ready:
                return "isReady"
            case Executing:
                return "isExecuting"
            case Finished:
                return "isFinished"
            }
        }
    }
    
    public enum Result {
        case Success
        case Cancelled
        case Error(NSError)
        public var success: Bool {
            switch self {
            case .Success: return true
            default: return false
            }
        }
        public var error: NSError? {
            switch self {
            case .Error(let error): return error
            default: return nil
            }
        }
    }
    
    // MARK: - Properties
    
    public private(set) var state = State.Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath())
            willChangeValueForKey(state.keyPath())
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath())
            didChangeValueForKey(state.keyPath())
        }
    }
    
    public private(set) var result : Result?
    
    public var future: Future<(), NSError> {
        return promise.future
    }
    
    let promise = Promise<(), NSError>()
    
    // MARK: - API for consumers
    
    public func manuallyStart() -> Future<(), NSError> {
        start()
        return future
    }
    
    // MARK: - API For subclass

    /// Should be overriden by subclass
    public func run() {
        // Subclass should perform actual work in here, and then call finish method with
        // result of the operation whenever done
        // Because this operation is async, finish does not need to be called before run() returns
    }
    
    /// Should be called by subclass
    public func finish(result: Result) {
        assert(state != .Finished, "Cannot finish again")
        self.result = result
        state = .Finished
        switch result {
        case .Success:
            promise.success()
        case .Error(let error):
            promise.failure(error)
        case .Cancelled:
            promise.failure(NSError(domain: "AsyncOperation", code: NSUserCancelledError, userInfo: nil))
            break
        }
    }
    
    // MARK: - NSOperation & NSOperation Queue
    
    public override func start() {
        if cancelled {
            finish(.Cancelled)
        } else {
            state = .Executing
            run()
        }
    }
    
    public override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    public override var executing: Bool {
        return state == .Executing
    }
    
    public override var finished: Bool {
        return state == .Finished
    }
    
    public override var asynchronous: Bool {
        return true
    }
}


