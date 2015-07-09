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
import BrightFutures

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
            perform {
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
