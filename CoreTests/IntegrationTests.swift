//
//  MeteorTests.swift
//  S10
//
//  Created by Tony Xiao on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import Core
import Meteor
import OHHTTPStubs
import SwiftyJSON
import RealmSwift

var meteor: MeteorService!
var env: Environment!
var videoService: VideoService!

class IntegrationTests : XCTestCase {

    let PHONE_NUMBER = "6172596512"
    let CONNECTION_PHONE_NUMBER = "6501001010"

    override class func setUp() {
        super.setUp()
        meteor = MeteorService(serverURL: NSURL("ws://s10-dev.herokuapp.com/websocket"))
        env = Environment(provisioningProfile: nil)
        videoService = VideoService(meteorService: meteor)
    }
    
    override class func tearDown() {
        super.tearDown()
        meteor.logout()
    }
    
    override func setUp() {
        super.setUp()
        Realm.defaultPath = NSHomeDirectory().stringByAppendingPathComponent("test.realm")

        deleteRealmFilesAtPath(Realm.defaultPath)
        meteor.delegate = self

        OHHTTPStubs.stubRequestsPassingTest({ request in
            let isAzure = request.URL!.host!.rangeOfString("s10tv.blob.core.windows.net") != nil
            return isAzure
            }, withStubResponse: { _ in
                let stubData = "Hello World!".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
    }

    func testConnection() {
        meteor.startup()
        expect { meteor.connected }.toEventually(beTrue(), timeout: 2)
    }

    func testLoginWithPhoneNumber() {
        var expectation = self.expectationWithDescription("Log in to meteor with phone number")

        let PHONE_NUMBER = "6172596512"
        meteor.loginWithPhoneNumber(PHONE_NUMBER).subscribeError({ (error) -> Void in
            expect(error) == nil
        }, completed: { () -> Void in
            expect(meteor.userID).notTo(beNil())
            expect(meteor.user!.documentID!).notTo(beNil())
            expectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testSendVideo() {
        var candidateUserId: String?
        var userId: String?
        var connectionId: String?

        var expectation = self.expectationWithDescription("Log in to meteor with phone number")

        let signal = meteor.newUser(self.CONNECTION_PHONE_NUMBER).flattenMap { res in
            candidateUserId = JSON(res)["id"].string!
            return meteor.vet(candidateUserId!)
        }.then {
            return meteor.loginWithPhoneNumber(self.PHONE_NUMBER)
        }.then {
            userId = meteor.userID
            return meteor.vet(userId!)
        }.then {
            return meteor.connectWithNewUser(candidateUserId!)
        }.flattenMap { res in
            let filePath = NSHomeDirectory().stringByAppendingPathComponent("test.txt")
            expect("hello world".writeToFile(
                filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)) == true
            let url = NSURL(string: filePath)
            let connection = Connection.all().fetch().first as! Connection
            videoService.sendVideoMessage(connection, localVideoURL: url!)
            return RACSignal.empty()
        }

        var expectedNotifications = 2
        let token = Realm().addNotificationBlock { notification, realm in
            if (expectedNotifications == 1) {
                expectation.fulfill()
            } else {
                expectedNotifications--
            }
        }

        signal.subscribeError { (error) -> Void in
            expect(error).to(beNil())
        }

        self.waitForExpectationsWithTimeout(30.0, handler: nil)
    }

    private func deleteRealmFilesAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(path, error: nil)
        let lockPath = path + ".lock"
        fileManager.removeItemAtPath(lockPath, error: nil)
    }
}

// MARK: Meteor Logging
extension IntegrationTests : METDDPClientDelegate {
    func client(client: METDDPClient, willSendDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP > \(message)")
    }
    func client(client: METDDPClient, didReceiveDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP < \(message)")
    }
}