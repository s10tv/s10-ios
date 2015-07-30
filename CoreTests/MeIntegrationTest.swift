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

    func testMyProfile() {
        let expectation = expectationWithDescription("Can subscribe to Name")
        self.meteor.loginWithDigits(userId: "0", authToken: "0", authTokenSecret: "0",
            phoneNumber: "0").subscribeErrorOrCompleted { error in
                expect(error).to(beNil())
                self.vm = MeViewModel(meteor: self.meteor, taskService: self.taskService)
                self.vm.subscription.ready.onComplete { result in
                    expect(result.error).to(beNil())
                    // last name changes, so match on first name
                    expect(self.vm.displayName.value).toEventually(match("^Lya"))

                    expect(self.vm.avatar.value?.url.absoluteString!).toEventually(
                        match("^http:\\/\\/images\\.gotinder\\.com.+jpg$"))

                    expect(self.vm.username.value).toEventually(match("^[A-Za-z0-9]+$"))

                    let profileVm = self.vm.profileVM()
                    let profiles : [ProfileCoverViewModel]? = profileVm?.coverVM.value

                    // there should be one profile (the one for the current user)
                    expect(profiles?.count) == 1
                    let profile = profiles?.first!

                    // the user should have a github profile image and a twitter profile image
                    expect(profile?.selectorImages.count) == 2
                    let profileImages: [String]? = profile?.selectorImages.value.map {
                        $0.url.absoluteString!
                    }

                    let twitterImage = profileImages?.filter { $0.rangeOfString("twitter") != nil }
                    let githubImage = profileImages?.filter { $0.rangeOfString("github") != nil }

                    expect(twitterImage?.count) == 1
                    expect(githubImage?.count) == 1

                    expectation.fulfill()
            }

        }

        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
}