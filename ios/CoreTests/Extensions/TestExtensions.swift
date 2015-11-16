//
//  TestExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import ReactiveCocoa
import Foundation
import XCTest
import Nimble
import Core

// MARK: - Async Testing with Futures

extension XCTestExpectation {
    public func fulfill<T, E>(@noescape futureProducer: () -> Future<T, E>) -> Disposable {
        return futureProducer().observe { _ in self.fulfill() }
    }
    
    public func fulfill<T, E>(future: Future<T, E>) -> Disposable {
        return fulfill { future }
    }
}

extension XCTestCase {
    func expectFulfill(description: String = "expectation", @noescape block: (()-> ()) ->  ()) {
        let expectation = expectationWithDescription(description)
        block { expectation.fulfill() }
    }
}

public class AsyncTestCase : XCTestCase {
    var disposable: CompositeDisposable!
    
    public override func setUp() {
        super.setUp()
        disposable = CompositeDisposable()
    }
    
    public override func tearDown() {
        super.tearDown()
        disposable.dispose()
    }
    
    public func expectComplete<T, E>(description: String = "future completed", @noescape futureProducer: () -> Future<T, E>) {
        disposable.addDisposable(expectationWithDescription(description).fulfill(futureProducer))
    }
}

// MARK: - Nimble extensions

public func fail(error: NSError, file: String = __FILE__, line: UInt = __LINE__) {
    fail("fail() - \(error)", file: file, line: line)
}

public func existOnDisk() -> MatcherFunc<NSURL> {
    return MatcherFunc { expression, failureMessage in
        failureMessage.postfixMessage = "exist on disk"
        do {
            return try expression.evaluate()?.checkResourceIsReachableAndReturnError(nil) ?? false
        } catch {
            return false
        }
    }
}