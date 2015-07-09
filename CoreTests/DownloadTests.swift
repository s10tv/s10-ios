//
//  DownloadTests.swift
//  DownloadTests
//
//  Created on 1/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import Core
import Nimble
import ReactiveCocoa
import BrightFutures

extension SignalProducer {
    func fulfill(expectation: XCTestExpectation) -> SignalProducer<T, E> {
        return self |> on(disposed: {
            expectation.fulfill()
        })
    }
    
    func onNext(next: T -> ()) {
        start(next: next)
        
    }
}

extension XCTestExpectation {
    func fulfill<T, E>(@noescape futureProducer: () -> Future<T, E>) {
        let future = futureProducer()
        future.andThen { _ in } .onComplete { _ in self.fulfill() }
    }
    
    func fulfill<T, E>(future: Future<T, E>) {
        fulfill({ future })
    }
}

extension XCTestCase {
    func expectComplete<T, E>(description: String = "future completed", @noescape futureProducer: () -> Future<T, E>) {
        expectationWithDescription(description).fulfill(futureProducer)
    }
}

public func firstly<T, E>(@noescape futureProducer: () -> Future<T, E>) -> Future<T, E> {
    return futureProducer()
}

public func fail(error: NSError, file: String = __FILE__, line: UInt = __LINE__) {
    fail("fail() - \(error)", file: file, line: line)
}

class DownloadTests: XCTestCase {
    
    var downloadService: DownloadService!
    let remoteURL = NSURL("http://s10tv.blob.core.windows.net/s10tv-test/public.mp4")
    let bogusURL = NSURL("https://s10tv.blob.core.windows.net/s10tv-test/bogus.mp4")
    
    override func setUp() {
        super.setUp()
        // NOTE: Logic testing does not appear to support background session type, returns unknown error otherwise
        downloadService = DownloadService(identifier: "tv.s10.test", sessionType: .Ephemeral)
    }
    
    override func tearDown() {
        super.tearDown()
        downloadService.removeAllFiles()
    }
    
    func testDownloadSuccessful() {
        expectComplete {
            firstly {
                downloadService.downloadFile(remoteURL)
            }.onSuccess {
                expect($0).toNot(beNil())
            }.onFailure {
                fail($0)
            }
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testNoDuplicateRequests() {
        downloadService.downloadFile(remoteURL)
        downloadService.downloadFile(remoteURL)
        expect(self.downloadService.requestsByKey.count).to(equal(1))
    }
    
//    func testDownloadFailure() {
//        
//    }
//    
//    func testCancelRequest() {
//        
//    }
//    
//    func testResumeRequest() {
//        
//    }
}
