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
import SwiftyJSON
import OHHTTPStubs

class AzureUploaderTest: XCTestCase {

    let UPLOAD_URL = "http://s10tv.blob.core.windows.net/s10tv-dev/" +
        "testblob?se=2015-11-16T11%3A41%3A47Z&sp=w&sv=2014-02-14&sr=b&sig=cdVLZSMRLqWOwEJj%2BAadJ0QpLJ9rK7tEQNomCMaNcXw%3D"
    let PHONE_NUMBER = "6172596512"
    let CONNECTION_PHONE_NUMBER = "6501001010"

    var meteorService: MeteorService!
    var toTest: AzureUploader!

    var userId: String?
    var candidateUserId: String?
    var coverFrameUrl: String?
    var videoUrl: String?

    override func setUp() {
        super.setUp()
        meteorService = MeteorService(serverURL: NSURL("ws://s10-dev.herokuapp.com/websocket"))
        meteorService.delegate = self
        meteorService.startup()
        self.toTest = AzureUploader(meteorService: meteorService)
        OHHTTPStubs.stubRequestsPassingTest({ request in
            let isAzure = request.URL!.host!.rangeOfString("s10tv.blob.core.windows.net") != nil
            return isAzure
            }, withStubResponse: { _ in
                let stubData = "Hello World!".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNewMessage() {
        var expectation = self.expectationWithDescription("Send Message")

        let signal = self.meteorService.newUser(self.CONNECTION_PHONE_NUMBER).flattenMap { res in
            self.candidateUserId = JSON(res)["id"].string!
            println("candidateId: " + self.candidateUserId!)
            return self.meteorService.vet(self.candidateUserId!)
        }.then {
            return self.meteorService.loginWithPhoneNumber(self.PHONE_NUMBER)
        }.then {
            self.userId = self.meteorService.userID!
            println("userId:" + self.userId!)
            return self.meteorService.vet(self.userId!)
        }.then {
            return self.meteorService.connectUsers(
                self.userId!, secondUserId: self.candidateUserId!)
        }.flattenMap { res in
            let filePath = NSHomeDirectory().stringByAppendingPathComponent("test.txt")
            expect("hello world".writeToFile(
                filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)) == true

            let url = NSURL(string: filePath)
            let connectionId = res as! String
            return self.toTest.uploadFile(connectionId, localUrl: url!)
        }.flattenMap { res in
            let status = res as! Int
            expect(status) == 1
            return RACSignal.empty()
        }.then {
            return self.meteorService.clearMessages()
        }.then {
            return self.meteorService.clearConnections()
        }.then {
            return self.meteorService.clearVideos()
        }.then {
            return self.meteorService.clearCandidates()
        }.then {
            return self.meteorService.clearUsers()
        }.subscribeError({ (error) -> Void in
            println(error)
            expect(error) == nil
        }, completed: { () -> Void in
            expectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(30.0, handler: nil)
    }
}

// MARK: Meteor Logging
extension AzureUploaderTest : METDDPClientDelegate {
    func client(client: METDDPClient, willSendDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP > \(message)")
    }
    func client(client: METDDPClient, didReceiveDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP < \(message)")
    }
}