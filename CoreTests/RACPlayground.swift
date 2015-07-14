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
    
    func testExpectFulfill() {
        expectFulfill { fulfill in
            let block = { fulfill() }
            Async.main(after: 0.5) {
                block()
            }
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    var strongMutable: MutableProperty<Int>!
    
    func testMutablePropertyDisposeCompletesSignal() {
        weak var wMutable: MutableProperty<Int>?
        let signalComplete = expectationWithDescription("signal complete")
        autoreleasepool {
            let mutable = MutableProperty(0)
            wMutable = mutable
            expect(wMutable).toNot(beNil())
            wMutable?.producer.start(completed: {
                signalComplete.fulfill()
            })
        }
        expect(wMutable).to(beNil())
        
        strongMutable = MutableProperty(0)
        let signalDoNotComplete = expectationWithDescription("No complete")
        strongMutable.producer.start(completed: {
            fail("expect property to not complete")
        })
        Async.main(after: 0.5) {
            signalDoNotComplete.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testPropertyRetainsMutable() {
        weak var weakMP: MutableProperty<Int>?
        autoreleasepool {
            var pOf: PropertyOf<Int>!
            autoreleasepool {
                let mP = MutableProperty(0)
                weakMP = mP
                expect(weakMP).toNot(beNil())
                
                pOf = PropertyOf(mP)
            }
            expect(weakMP).toNot(beNil())
        }
        expect(weakMP).to(beNil())
    }
    
    func testTypedDynamicProperty() {
        let object = TestNSObject()
        // Sanity
        let prop = DynamicProperty(object: object, keyPath: "strValue")
        expect(prop.value as? String).to(equal("TestStr"))
        object.setValue(nil, forKey: "strValue")
        expect(prop.value).to(beNil())
        
        // KVC property
        let typedProp = prop.optional(String)
        expect(typedProp.value).to(beNil())
        object.setValue("test2", forKey: "strValue")
        expect(typedProp.value).to(equal("test2"))
        
        // Backwards
        typedProp.value = "test3"
        expect(typedProp.value).to(equal("test3"))
        expect(prop.value as? String).to(equal("test3"))
        expect(object.strValue).to(equal("test3"))
      
        // propertyof
        let pof = typedProp |> readonly
        expect(pof.value).to(equal("test3"))
        
        object.strValue = "test4"
        expect(pof.value).to(equal("test4"))
        expect(typedProp.value).to(equal("test4"))
        expect(prop.value as? String).to(equal("test4"))
        
    }
    
    func testTypedPrimitiveDynamicProperty() {
        let object = TestNSObject()
        
        let prop = object.dyn("intValue")

        // dyn.typed
        expect(prop.value as? Int).to(equal(25))
        
        let typed2 = prop.optional(Int)
        expect(typed2.value).to(equal(25))

        object.intValue = 33
        expect(typed2.value).to(equal(33))
        
        let primitiveTyped = prop.force(Int)
        expect(primitiveTyped.value).to(equal(33))
        
        object.intValue = 123
        expect(primitiveTyped.value).to(equal(123))
        
        let pof = object.dyn("intValue").force(Int) |> readonly
        object.intValue = 333
        expect(pof.value).to(equal(333))
        
    }
    
    func testRacFuture() {
        let promise = RACPromise<Int, NSError>()
        let future = promise.future
        let expectation = expectationWithDescription("success")
        future.onSuccess { val in
            expect(val).to(equal(3))
            expect(future.value).to(equal(3))
            expectation.fulfill()
        }
        promise.success(3)
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testRacFutureFail() {
        let promise = RACPromise<Int, NSError>()
        let future = promise.future
        let expectation = expectationWithDescription("fail")
        future.onSuccess { val in
            fail("Should not get here")
            expectation.fulfill()
        }
        future.onFailure { err in
            expect(err).toNot(beNil())
            expectation.fulfill()
        }
        promise.failure(NSError(domain: "Test", code: 0, userInfo: nil))
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSignalToFuture() {
        let (signal, sink) = Signal<Int, NSError>.pipe()
        let future = signal |> toFuture
        let expectation = expectationWithDescription("success")
        future.onSuccess { val in
            expect(val).to(equal(5))
            expectation.fulfill()
        }

        let completed = expectationWithDescription("completed")
        future.producer
            |> flatMap(FlattenStrategy.Concat) { _ in
                return SignalProducer<Int, NSError>.empty
            }
            |> start(completed: {
                completed.fulfill()
            })
        
        let thenCompleted = expectationWithDescription("then completed")
        future.producer
            |> then(SignalProducer<Int, NSError>.empty)
            |> start(completed: {
                thenCompleted.fulfill()
            })
        
        sendNext(sink, 5)
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}


