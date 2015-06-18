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
        meteorService = MeteorService(serverURL: NSURL("wss://s10-dev.herokuapp.com/websocket"))
        meteorService.delegate = self
        meteorService.startup()
        self.toTest = AzureUploader(meteorService: meteorService)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShouldUploadCorrectly() {
        var expectation = self.expectationWithDescription("Upload to Azure")

        let data = "hello".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let signal : RACSignal = toTest.uploadFile(UPLOAD_URL, data: data)

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
            println("connetionId: ")
            println(res)
            return self.meteorService.startTask("MESSAGE", metadata: ["connectionId": res])
        }.flattenMap { res in
            println(res)

            self.coverFrameUrl = JSON(res)["coverFrameUrl"].string!
            self.videoUrl = JSON(res)["videoUrl"].string!

            expect(self.coverFrameUrl) != nil
            expect(self.videoUrl) != nil

            let coverFrameData = self.coverFrameUrl!.dataUsingEncoding(
                NSUTF8StringEncoding, allowLossyConversion: true)!

            return self.toTest.uploadFile(self.coverFrameUrl!, data: coverFrameData)
        }.flattenMap { res in
            let statusCode = res as! Int
            println(statusCode)

            expect(statusCode).to(beGreaterThanOrEqualTo(200))
            expect(statusCode).to(beLessThan(300))

            let videoUrlData = self.videoUrl!.dataUsingEncoding(
                NSUTF8StringEncoding, allowLossyConversion: true)!
            return self.toTest.uploadFile(self.videoUrl!, data: videoUrlData)
        }.flattenMap { res in
            let statusCode = res as! Int
            println(statusCode)

            expect(statusCode).to(beGreaterThanOrEqualTo(200))
            expect(statusCode).to(beLessThan(300))
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