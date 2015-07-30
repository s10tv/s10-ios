//
//  MeIntegrationTest.swift
//  S10
//
//  Created by Qiming Fang on 7/25/15.
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

class MeIntegrationTest : IntegrationTestEnvironment {

    var vm: MeViewModel!

    func testMyName() {
        let expectation = expectationWithDescription("Can subscribe to Name")
        self.meteor.loginWithDigits(userId: "0", authToken: "0", authTokenSecret: "0",
            phoneNumber: "0").subscribeErrorOrCompleted { error in
                expect(error).to(beNil())
                self.vm = MeViewModel(meteor: self.meteor, taskService: TaskService(meteorService: self.meteor))
                self.vm.subscription.ready.onComplete { result in
                    expect(result.error).to(beNil())
                    expect(self.vm.displayName.value).toEventually(equal("Lya Keebler"))
                    expectation.fulfill()
            }

        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
}