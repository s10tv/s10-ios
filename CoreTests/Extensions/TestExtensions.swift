//
//  TestExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import BrightFutures

// MARK: - Async Testing with Futures

extension XCTestExpectation {
    public func fulfill<T, E>(token: InvalidationToken? = nil, @noescape futureProducer: () -> Future<T, E>) {
        let future = futureProducer().andThen { _ in }
        if let token = token {
            future.onComplete(token: token) { _ in self.fulfill() }
        } else {
            future.onComplete { _ in self.fulfill() }
        }
    }
    
    public func fulfill<T, E>(token: InvalidationToken? = nil, future: Future<T, E>) {
        fulfill(token: token) { future }
    }
}

extension XCTestCase {
    func expectFulfill(_ description: String = "expectation", @noescape block: (()-> ()) ->  ()) {
        let expectation = expectationWithDescription(description)
        block { expectation.fulfill() }
    }
}

public class AsyncTestCase : XCTestCase {
    var invalidationTokens: [InvalidationToken] = []
    
    public override func tearDown() {
        super.tearDown()
        for token in invalidationTokens {
            token.invalidate()
        }
        invalidationTokens.removeAll(keepCapacity: false)
    }
    
    public func expectComplete<T, E>(_ description: String = "future completed", @noescape futureProducer: () -> Future<T, E>) {
        let token = InvalidationToken()
        expectationWithDescription(description).fulfill(token: token, futureProducer: futureProducer)
    }
}

// MARK: - Nimble extensions

public func fail(error: NSError, file: String = __FILE__, line: UInt = __LINE__) {
    fail("fail() - \(error)", file: file, line: line)
}

public func existOnDisk() -> MatcherFunc<NSURL> {
    return MatcherFunc { expression, failureMessage in
        failureMessage.postfixMessage = "exist on disk"
        return expression.evaluate()?.checkResourceIsReachableAndReturnError(nil) ?? false
    }
}