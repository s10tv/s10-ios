//
//  CoreTests.swift
//  CoreTests
//
//  Created on 1/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import Core
import Nimble


class XCTestCaseExample: XCTestCase {
    
    var downloadService: DownloadService!
    let remoteURL = NSURL("https://s10tv.blob.core.windows.net/s10tv-test/public.mp4")
    let bogusURL = NSURL("https://s10tv.blob.core.windows.net/s10tv-test/bogus.mp4")
    
    override func setUp() {
        super.setUp()
        downloadService = DownloadService(identifier: "tv.s10.test")
    }
    
    override func tearDown() {
        super.tearDown()
        downloadService.removeAllFiles()
    }
    
    func testDownloadSuccessful() {
        let expectation = expectationWithDescription("download complete")
        
        downloadService.downloadFile(remoteURL) { localURL in
            println("local \(localURL)")
            expect(localURL).toNot(beNil())
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(30, handler: nil)
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
