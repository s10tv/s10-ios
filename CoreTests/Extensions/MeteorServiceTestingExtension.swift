//
//  MeteorAdminService.swift
//  S10
//
//  Created by Qiming Fang on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa
import SwiftyJSON
@testable import Core

extension MeteorService {
    func clearUserData(userId: String) -> Future<(), NSError> {
        return meteor.call("dev/user/remove", userId)
    }

    func testNewUser() -> Future<(), NSError> {
        return meteor.call("testing/user/create")
    }

    func testLogin(userId: String) -> Future<(), NSError> {
        return meteor.login("login", [
            "debug": [
                "userId": userId,
            ]
        ])
    }

    func connectWithNewUser() -> Future<(), NSError> {
        return meteor.call("dev/user/connectWithNewUser")
    }

    func vet(userId: String) -> Future<(), NSError> {
        return meteor.call("admin/user/vet", userId)
    }

    public func connectUsers(firstUserId: String, secondUserId: String) -> Future<(), NSError> {
        var id: String = ""

        return meteor.callMethod("candidate/new", params: [firstUserId, secondUserId]).future
         .flatMap { candidateId in
            id = candidateId as! String
            return self.meteor.call("candidate/makeChoice", id, "yes")
        }.flatMap {
            return self.meteor.call("candidate/makeChoiceForInverse", id, "yes")
        }
    }
}