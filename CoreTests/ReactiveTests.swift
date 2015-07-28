//
//  ReactiveTests.swift
//  S10
//
//  Created by Tony Xiao on 7/28/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import XCTest
import Nimble
import Foundation
import ReactiveCocoa
import Core

class ReactiveTests : XCTestCase {
    
    func testFutureUnaryLift() {
        let promise = Promise<Int, ReactiveCocoa.NoError>()
        let expectation = expectationWithDescription("Promise fulfills")
        promise.future
            |> map {
                return "\($0)"
            }
            |> onSuccess { value in
                expect(value) == "55"
                expectation.fulfill()
            }
        promise.success(55)
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testFutureOperator() {
        let promise = Promise<Int, ReactiveCocoa.NoError>()
        let expectation = expectationWithDescription("Promise fulfills")
        let completed = expectationWithDescription("completed")
        promise.future
            |> onSuccess { intValue in
                expect(intValue) == 55
                expectation.fulfill()
            }
            |> onComplete { _ in
                completed.fulfill()
            }

        promise.success(55)
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}