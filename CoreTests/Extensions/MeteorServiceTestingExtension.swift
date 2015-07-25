//
//  MeteorAdminService.swift
//  S10
//
//  Created by Qiming Fang on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import Meteor
import ReactiveCocoa
import SwiftyJSON

extension MeteorService {
    func clearUserData(userId: String) -> RACSignal {
        return self.meteor.call("dev/user/remove", [userId])
    }

    func testNewUser() -> RACSignal {
        return self.meteor.call("testing/user/create", [])
    }

    func testLogin(userId: String) -> RACSignal {
        return self.meteor.call("login", [[
            "debug": [
                "userId": userId,
            ]
        ]])
    }

    func connectWithNewUser() -> RACSignal {
        return meteor.call("dev/user/connectWithNewUser", [])
    }

    func vet(userId: String) -> RACSignal {
        return self.meteor.call("admin/user/vet", [userId])
    }

    public func connectUsers(firstUserId: String, secondUserId: String) -> RACSignal {
        var id: String = ""

        return self.meteor.call("candidate/new", [firstUserId, secondUserId])
        .flattenMap { candidateId in
            id = candidateId as! String
            return self.meteor.call("candidate/makeChoice", [candidateId, "yes"])
        }.then {
            return self.meteor.call("candidate/makeChoiceForInverse", [id, "yes"])
        }
    }
}