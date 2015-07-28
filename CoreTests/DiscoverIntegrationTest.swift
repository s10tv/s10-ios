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

    func testDiscover() {
        doWhileAuthenticated { done in
            self.vm = DiscoverViewModel(meteor: self.meteor)
//            expect(model.candidates.count).toEventually(equal(1))
//            let count = model.candidates.count
            
            self.vm.subscription.ready.onComplete { result in
                expect(result.error).to(beNil())
                expect(self.vm.candidates.count) > 0
//                expect(self.vm.candidates.first?.displayName) == "Tony Xiao"
                done()
            }
        }
    }

}