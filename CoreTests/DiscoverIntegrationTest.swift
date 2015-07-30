//
//  DiscoverIntegrationTest.swift
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

class DiscoverIntegrationTest : IntegrationTestEnvironment {
    
    var vm: DiscoverViewModel!

    func testDiscoverUsers() {
        let expectation = expectationWithDescription("Can discover users")
        self.meteor.loginWithDigits(userId: "0", authToken: "0", authTokenSecret: "0",
            phoneNumber: "0").subscribeErrorOrCompleted { error in
                expect(error).to(beNil())
                self.vm = DiscoverViewModel(meteor: self.meteor, taskService: self.taskService)
                self.vm.subscription.ready.onComplete { result in
                    expect(result.error).to(beNil())

                    expect(self.vm.candidates.count).toEventually(beGreaterThan(0))

                    println(self.vm.candidates[0].displayName)

//                    expect(self.vm.candidates[0].displayName.length).toEventually(beGreaterThan(0))
//                    expect(self.vm.candidates[0].employer.length).toEventually(beGreaterThan(0))
//                    expect(self.vm.candidates[0].jobTitle.length).toEventually(beGreaterThan(0))

                    expectation.fulfill()
                }
                
        }
        waitForExpectationsWithTimeout(15, handler: nil)
    }
}