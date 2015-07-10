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
import BrightFutures

class RACPlayground : AsyncTestCase {

    func testSignalProducer() {
        let (producer, sink) = SignalProducer<Int, ReactiveCocoa.NoError>.buffer()
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
        var signal: Signal<NSDate, ReactiveCocoa.NoError>!
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
    
    func testFutureToSignal() {
        let promise = Promise<Int, NSError>()
        let sp = promise.future.signalProducer()
        
        let completeCalled = expectationWithDescription("complete called")
        sp.start(completed: {
            completeCalled.fulfill()
        })
        promise.success(3)
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFutureMaterialize() {
        let promise = Promise<Int, NSError>()

        let sp = promise.future.signalProducer()
            |> materialize
            |> dematerialize
        
        promise.failure(NSError(domain: "", code: 0, userInfo: nil))
        
        let errorReceived = expectationWithDescription("error received")
        sp.future().onFailure { _ in
            errorReceived.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testExpectComplete() {
        expectComplete { () -> Future<(), NSError> in
            let (producer, sink) = SignalProducer<(), NSError>.buffer(1)
            sendCompleted(sink)
            return producer.future()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
