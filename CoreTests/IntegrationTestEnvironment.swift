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
import ReactiveCocoa
import Meteor
import OHHTTPStubs
import SwiftyJSON
import RealmSwift
import Core

var environment: Environment!

class IntegrationTestEnvironment : XCTestCase {
    var meteor: MeteorService!
    var taskService: TaskService!
    var notificationToken: NotificationToken?
    var userId: String?
    var candidateUserId: String?
    var connectionUserId: String?

    let PHONE_NUMBER = "6172596512"
    let CONNECTION_PHONE_NUMBER = "6501001010"
    let bundle = NSBundle(forClass: IntegrationTestEnvironment.self)

    override class func setUp() {
        super.setUp()
        environment = Environment(provisioningProfile: nil)
        Realm.defaultPath = NSHomeDirectory().stringByAppendingPathComponent("test.realm")
        deleteRealmFilesAtPath(Realm.defaultPath)
        OHHTTPStubs.stubRequestsPassingTest({ request in
            let isAzure = request.URL!.host!.rangeOfString("s10tv.blob.core.windows.net") != nil
            return isAzure
            }, withStubResponse: { _ in
                let stubData = "Hello World!".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
    }

    override func setUp() {
        meteor = MeteorService(serverURL: NSURL("ws://localhost:3000/websocket"))
        meteor.startup()
        taskService = TaskService(meteorService: meteor)
    }

    override func tearDown() {
        super.tearDown()
        meteor.logout()
    }

    override class func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func getResource(filename: String) -> NSURL? {
        return bundle.URLForResource(filename.stringByDeletingPathExtension, withExtension: filename.pathExtension)
    }

    func whileAuthenticated(block: () -> (RACSignal)) {
        let expectation = expectationWithDescription("Test Finished")
        self.meteor.testNewUser().flattenMap { res in
            self.userId = res["userId"] as? String
            self.candidateUserId = res["candidateUserId"] as? String
            self.connectionUserId = res["connectionUserId"] as? String
            return self.meteor.testLogin(self.userId!)
        }.then {
            return block()
        }.subscribeErrorOrCompleted { error in
            self.meteor.clearUserData(self.userId!)
            self.meteor.clearUserData(self.candidateUserId!)
            self.meteor.clearUserData(self.connectionUserId!)

            expect(error).to(beNil())
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(45, handler: nil)
    }

    class func deleteRealmFilesAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(path, error: nil)
        let lockPath = path + ".lock"
        fileManager.removeItemAtPath(lockPath, error: nil)
    }
}
