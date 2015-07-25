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

    func testDiscover() {
        whileAuthenticated {
            let model = DiscoverViewModel(meteor: self.meteor)
            expect(model.candidates.count).toEventually(equal(1))
            let count = model.candidates.count
            println("Here \(count)")

            return RACSignal.empty() //subject.replay()
        }
    }

}