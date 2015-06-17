//
//  UploaderTest.swift
//  S10
//
//  Created by Qiming Fang on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Core
import XCTest
import Nimble
import ReactiveCocoa

class AzureUploaderTest: XCTestCase {

    let UPLOAD_URL = "http://s10tv.blob.core.windows.net/s10tv-dev/" +
        "testblob?se=2015-11-16T11%3A41%3A47Z&sp=w&sv=2014-02-14&sr=b&sig=cdVLZSMRLqWOwEJj%2BAadJ0QpLJ9rK7tEQNomCMaNcXw%3D"

    var toTest: AzureUploader! = nil

    override func setUp() {
        super.setUp()
        self.toTest = AzureUploader()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShouldUploadCorrectly() {
        var expectation = self.expectationWithDescription("Upload to Azure")

        let data = "hello".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let signal : RACSignal = toTest.upload(UPLOAD_URL, data: data)

        signal.subscribeNext { (response) -> Void in
            let statusCode = response as! Int
            expect(statusCode).to(beGreaterThanOrEqualTo(200))
            expect(statusCode).to(beLessThan(300))
            expectation.fulfill()
        }

        signal.subscribeError { (error) -> Void in
            XCTFail("Error uploading to Azure")
        }

        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}