//
//  RACPlayground.swift
//  S10
//
//  Created by Tony Xiao on 7/8/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import ReactiveCocoa
import Async
import Nimble

class RACPlayground : XCTestCase {
    
    func testSignalProducer() {
        let (producer, sink) = SignalProducer<Int, NoError>.buffer()
        producer
            |> on(next: { value in
                fail("unexpectedly received value")
            })
        sendNext(sink, 5)
        
        let expectation = expectationWithDescription("0.5 elapses")
        Async.main(after: 0.5) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testHotSignal() {
        let producer = timer(0.1, onScheduler: QueueScheduler.mainQueueScheduler)
        var signal: Signal<NSDate, NoError>!
        var disposable: Disposable!
        producer.startWithSignal { s, d in
            signal = s
            disposable = d
        }
        var expectation = expectationWithDescription("map hot signal gets executed")
        let transform: NSDate -> String = {
            expectation.fulfill()
            disposable.dispose()
            return $0.description
        }
        
        signal |> map(transform)
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testPromise() {
        let promise = RACPromise<Int, NSError>()
        let cancelCalled = expectationWithDescription("cancel called")
        promise.future.onCancel {
            cancelCalled.fulfill()
        }
        promise.cancel()
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
}
