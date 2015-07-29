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
        meteor = MeteorService(serverURL: NSURL("ws://s10-test.herokuapp.com/websocket"))
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
    
    func doWhileAuthenticated(block: (Void -> Void) -> Void) {
        let expectation = expectationWithDescription("Test Finished")
        let cleanup: () -> () = {
            self.userId.map { self.meteor.clearUserData($0) }
            self.candidateUserId.map { self.meteor.clearUserData($0) }
            self.connectionUserId.map { self.meteor.clearUserData($0) }
            expectation.fulfill()
        }
        self.meteor.testNewUser().flattenMap { res in
            self.userId = res["userId"] as? String
            self.candidateUserId = res["candidateUserId"] as? String
            self.connectionUserId = res["connectionUserId"] as? String
            return self.meteor.testLogin(self.userId!)
        }.subscribeErrorOrCompleted { error in
            expect(error).to(beNil())
            block(cleanup)
        }
        waitForExpectationsWithTimeout(45, handler: nil)
    }


    func whileAuthenticated(block: () -> (RACSignal)) {
        doWhileAuthenticated { callback in
            block().subscribeErrorOrCompleted { error in
                expect(error).to(beNil())
                callback()
            }
        }
    }

    class func deleteRealmFilesAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(path, error: nil)
        let lockPath = path + ".lock"
        fileManager.removeItemAtPath(lockPath, error: nil)
    }
}
