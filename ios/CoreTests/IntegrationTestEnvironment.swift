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

var environment: Environment!

class IntegrationTestEnvironment : XCTestCase {
    var meteor: MeteorService!
    var taskService: TaskService!
    var notificationToken: NotificationToken?
    let bundle = NSBundle(forClass: IntegrationTestEnvironment.self)

    override class func setUp() {
        super.setUp()
        environment = Environment(provisioningProfile: nil)
        let path = NSURL(fileURLWithPath: NSHomeDirectory()).URLByAppendingPathComponent("test.realm").path
        Realm.Configuration.defaultConfiguration.path = path
        deleteRealmFilesAtPath(path!)
        OHHTTPStubs.stubRequestsPassingTest({ request in
            let isAzure = request.URL!.host!.rangeOfString("s10tv.blob.core.windows.net") != nil
            return isAzure
            }, withStubResponse: { _ in
                let stubData = "Hello World!".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
    }

    override class func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
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

    func getResource(filename: String) -> NSURL? {
        let file = NSURL(fileURLWithPath: filename)
        return bundle.URLForResource(file.URLByDeletingPathExtension?.lastPathComponent, withExtension: file.pathExtension)
    }

    // MARK: - Private Functions

    private class func deleteRealmFilesAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        _ = try? fileManager.removeItemAtPath(path)
        let lockPath = path + ".lock"
        _ = try? fileManager.removeItemAtPath(lockPath)
    }
}
