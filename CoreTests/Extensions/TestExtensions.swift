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

extension XCTestExpectation {
    public func fulfill<T, E>(@noescape futureProducer: () -> Future<T, E>) {
        let future = futureProducer()
        future.andThen { _ in } .onComplete { _ in self.fulfill() }
    }
    
    public func fulfill<T, E>(future: Future<T, E>) {
        fulfill({ future })
    }
}

extension XCTestCase {
    func expectComplete<T, E>(description: String = "future completed", @noescape futureProducer: () -> Future<T, E>) {
        expectationWithDescription(description).fulfill(futureProducer)
    }
}

public func fail(error: NSError, file: String = __FILE__, line: UInt = __LINE__) {
    fail("fail() - \(error)", file: file, line: line)
}
