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
import Async

class DownloadTests: AsyncTestCase {
    
    var downloadService: DownloadService!
    let remoteURL = NSURL("http://s10tv.blob.core.windows.net/s10tv-test/public.mp4")
    let bogusURL = NSURL("http://s10tv.blob.core.windows.net/s10tv-test/bogus.mp4")
    
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
    
    func testDownloadCancel() {
        let shouldFail = expectationWithDescription("should fail")
        downloadService.downloadFile(remoteURL).onSuccess { _ in
            fail()
        }.onComplete { _ in
            shouldFail.fulfill()
        }
        expect(self.downloadService.futuresByKey.count).to(equal(1))
        expect(self.downloadService.requestsByKey.count).toEventually(equal(1))
        
        downloadService.removeFile(remoteURL)
        
        expect(self.downloadService.requestsByKey.count).toEventually(equal(0))
        expect(self.downloadService.futuresByKey.count).toEventually(equal(0))
        expect(self.downloadService.localURLForRemoteURL(self.remoteURL)).toNot(existOnDisk())

        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    
//    func testDownloadResume() {
//        expectFulfill("should fail") { f in
//            let fulfill = { f() }
//            downloadService.downloadFile(remoteURL).onSuccess { _ in
//                fail("should have been cancelled")
//            }.onComplete { _ in
//                fulfill()
//            }
//        }
//        
//        // TODO: Fix race condition. Cancellation does not work due to cache.fetch being async
//        // unless we first use toEventually to ensure that request exists
//        expect(self.downloadService.requestsByKey.count).toEventually(equal(1))
//        
//        expectFulfill("should have resumedata") { fulfill in
//            let key = downloadService.keyForURL(remoteURL)
//            // Wait until enough data is downloaded to have resumeData
//            Async.main(after: 1) {
//                self.downloadService.pauseDownloadFile(self.remoteURL).onSuccess { _ in
//                    fulfill()
////                    perform {
////                        self.downloadService.resumeDataCache.fetch(key)
////                    }.onSuccess { resumeData in
////                        expect(resumeData.length).to(beGreaterThan(0))
////                        fulfill()
////                    }.onFailure {
////                        fail($0)
////                        fulfill()
////                    }
//                }
//            }
//        }
//        
//        expect(self.downloadService.requestsByKey.count).toEventually(equal(0), timeout: 2)
//
//        expectComplete("2nd download") {
//            downloadService.downloadFile(remoteURL).onFailure {
//                fail($0)
//            }
//        }
//        
//        waitForExpectationsWithTimeout(10, handler: nil)
//        
//    }
    
    func testNoDuplicateRequests() {
        downloadService.downloadFile(remoteURL)
        downloadService.downloadFile(remoteURL)
        
        expect(self.downloadService.futuresByKey.count).to(equal(1))
    }
    
}
