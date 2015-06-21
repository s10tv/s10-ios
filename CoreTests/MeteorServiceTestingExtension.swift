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
    func clearMessages() -> RACSignal {
        var signals = [RACSignal]()
        Message.all().fetch().each { item in
            signals.append(self.meteor.call("/messages/remove", [["_id": item.documentID]]))
        }

        return RACSignal.merge(signals)
    }

    func clearConnections() -> RACSignal {
        var signals = [RACSignal]()
        Connection.all().fetch().each { item in
            signals.append(self.meteor.call("/connections/remove", [["_id": item.documentID]]))
        }

        return RACSignal.merge(signals)
    }

    func clearVideos() -> RACSignal {
        var signals = [RACSignal]()
        Video.all().fetch().each { item in
            signals.append(self.meteor.call("/videos/remove", [["_id": item.documentID]]))
        }

        return RACSignal.merge(signals)
    }

    func clearCandidates() -> RACSignal {
        var signals = [RACSignal]()
        Candidate.all().fetch().each { item in
            signals.append(self.meteor.call("/candidates/remove", [["_id": item.documentID]]))
        }

        return RACSignal.merge(signals)
    }

    func clearUsers() -> RACSignal {
        var signals = [RACSignal]()
        User.all().fetch().each { item in
            signals.append(self.meteor.call("/users/remove", [["_id": item.documentID]]))
        }

        return RACSignal.merge(signals)
    }

    func newUser(phoneNumber: String) -> RACSignal {
        return self.meteor.call("login", [[
            "phone-access": [
                "id": phoneNumber,
            ]
        ]])
    }

    func connectWithNewUser(otherUserId: String) -> RACSignal {
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