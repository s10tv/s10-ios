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

class DownloadTests: AsyncTestCase {
    
    var downloadService: DownloadService!
    let remoteURL = NSURL("http://s10tv.blob.core.windows.net/s10tv-test/public.mp4")
    let bogusURL = NSURL("https://s10tv.blob.core.windows.net/s10tv-test/bogus.mp4")
    
    override func setUp() {
        super.setUp()
        // NOTE: Logic testing does not appear to support background session type, returns unknown error otherwise
        downloadService = DownloadService(identifier: NSUUID().UUIDString, sessionType: .Ephemeral)
    }
    
    override func tearDown() {
        super.tearDown()
        downloadService.removeAllFiles()
    }
    
    func testDownloadSuccess() {
        let fileRemoved = expectationWithDescription("file removed")
        expectComplete {
            perform {
                downloadService.downloadFile(remoteURL)
            }.onSuccess { localURL in
                expect(localURL).to(existOnDisk())
                self.downloadService.removeFile(self.remoteURL).onSuccess {
                    expect(NSURL()).toNot(existOnDisk())
                    fileRemoved.fulfill()
                }
            }.onFailure { fail($0) }
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDownloadFailure() {
        expectFulfill { fulfill in
            let succeed = { fulfill() } // Work around swift compiler bug
            downloadService.downloadFile(bogusURL).onFailure { error in
                succeed()
            }.onSuccess { _ in
                fail()
            }
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    
    func testNoDuplicateRequests() {
        downloadService.downloadFile(remoteURL)
        downloadService.downloadFile(remoteURL)
        
        expect(self.downloadService.futuresByKey.count).to(equal(1))
    }
    
    
//
//    func testCancelRequest() {
//        
//    }
//    
//    func testResumeRequest() {
//        
//    }
}
