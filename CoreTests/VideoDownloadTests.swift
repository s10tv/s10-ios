//
//  VideoDownloadTests.swift
//  S10
//
//  Created by Tony Xiao on 7/11/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import Core
import Nimble
import Async
import RealmSwift

class VideoDownloadTests: AsyncTestCase {
    
    let goodURL = NSURL("http://s10tv.blob.core.windows.net/s10tv-test/public.mp4")
    let bogusURL = NSURL("http://s10tv.blob.core.windows.net/s10tv-test/bogus.mp4")
    var queue: NSOperationQueue!
    var videoId: String!
    var senderId: String!

    override class func setUp() {
        Realm.defaultPath = NSHomeDirectory().stringByAppendingPathComponent("test.realm")
        deleteRealmFilesAtPath(Realm.defaultPath)
    }

    class func deleteRealmFilesAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(path, error: nil)
        let lockPath = path + ".lock"
        fileManager.removeItemAtPath(lockPath, error: nil)
    }


    override func setUp() {
        super.setUp()
        // NOTE: Logic testing does not appear to support background session type, returns unknown error otherwise
        queue = NSOperationQueue()
        videoId = NSUUID().UUIDString
        senderId = NSUUID().UUIDString
    }
    
    override func tearDown() {
        super.tearDown()
        queue.cancelAllOperations()
    }
    
    func testDownloadSuccess() {
        expectComplete("download succeeds") { () -> Future<(), NSError> in
            let op = VideoDownloadOperation(videoId: videoId, senderId: senderId, remoteURL: goodURL)
            return queue.addAsyncOperation(op).onFailure {
                fail($0)
            }
        }
        waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    func testDownloadFailure() {
        expectComplete("download fails") { () -> Future<(), NSError> in
            let op = VideoDownloadOperation(videoId: videoId, senderId: senderId, remoteURL: bogusURL)
            return queue.addAsyncOperation(op).onSuccess {
                fail("Expected download to fail, instead it succeeded")
            }
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    // Don't test for now, need to figure out how to hook into download progress in order
    // to properly cancel after some progress is made but before file is fully downloaded
    func _testDownloadResume() {
        expectFulfill("download cancel then resumes") { fulfill in
            let op = VideoDownloadOperation(videoId: videoId, senderId: senderId, remoteURL: goodURL)
            let future = queue.addAsyncOperation(op).onSuccess {
                fail("Expect download to be cancelled, but got success")
                fulfill()
            }
            Async.main(after: 0.9) {
                expect(op.executing)
                op.cancel()
                expect(op.cancelled)
            }
            future.onFailure { _ in
                expect(op.finished).to(beTrue())
                let task = VideoDownloadTask.findByVideoId(self.videoId)
                expect(task).toNot(beNil())
                if let task = task {
                    let op2 = VideoDownloadOperation(task: task)
                    let future = self.queue.addAsyncOperation(op2)
                    expect(op2.executing)
                    expect(op2.resumeData).toNot(beNil())
                    future.onFailure {
                        fail($0)
                    }.onComplete { _ in
                        fulfill()
                    }
                } else {
                    fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
}