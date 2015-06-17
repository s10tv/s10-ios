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

var meteor: MeteorService!
var env: Environment!

class IntegrationTests : XCTestCase {
    
    override class func setUp() {
        super.setUp()
        meteor = MeteorService(serverURL: NSURL("ws://localhost:3000/websocket"))
        env = Environment(provisioningProfile: nil)
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        meteor.delegate = self
    }
    
    func testConnection() {
        meteor.startup()
        expect { meteor.connected }.toEventually(beTrue(), timeout: 2)
    }

    func testLoginWithPhoneNumber() {
        var expectation = self.expectationWithDescription("Log in to meteor with phone number")

        let PHONE_NUMBER = "6172596512"
        let signal = meteor.loginWithPhoneNumber(PHONE_NUMBER)

        signal.subscribeCompleted { () -> Void in
            expect(meteor.userID).notTo(beNil())
            expect(meteor.user!.firstName!).notTo(beNil())
            expectation.fulfill()
        }

        signal.subscribeError({ (error) -> Void in
            XCTFail("Error signing in to meteor with phone number")
        })

        self.waitForExpectationsWithTimeout(5.0, handler: nil)
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