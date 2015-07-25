//
//  MeIntegrationTest FUCK YOU!
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

    func testMyName() {
        whileAuthenticated {
            let model = MeViewModel(meteor: self.meteor)
            expect(model.displayName.value).toEventually(equal("Tony Xiao"), timeout: 5)
            return RACSignal.empty()
        }
    }
    
}