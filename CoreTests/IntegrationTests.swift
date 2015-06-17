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
        meteor = MeteorService(serverURL: NSURL("wss://s10-dev.herokuapp.com/websocket"))
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
}

// MARK: Meteor Logging
extension IntegrationTests : METDDPClientDelegate {
    func client(client: METDDPClient!, willSendDDPMessage message: [NSObject : AnyObject]!) {
        Log.verbose("DDP > \(message)")
    }
    func client(client: METDDPClient!, didReceiveDDPMessage message: [NSObject : AnyObject]!) {
        Log.verbose("DDP < \(message)")
    }
}