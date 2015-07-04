//
//  AsyncOperation.swift
//  S10
//
//  Created by Tony Xiao on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

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
//    // Doensn't actually work because operation gets deallocated
//    public var finishBlock: ((Result) -> (Void))? {
//        didSet(newValue) {
//            completionBlock = { [weak self] in
//                if let this = self {
//                    newValue?(this.result!)
//                }
//            }
//        }
//    }
    
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
    
    // MARK: - Overrides for sublcass
    
    public func run() {
        // Subclass should perform actual work in here, and then call finish method with
        // result of the operation whenever done
        // Because this operation is async, finish does not need to be called before run() returns
    }
    
    // MARK: - API For subclass
    
    public func finish(result: Result) {
        assert(state != .Finished, "Cannot finish again")
        self.result = result
        state = .Finished
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


