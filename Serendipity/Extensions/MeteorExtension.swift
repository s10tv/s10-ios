//
//  MeteorExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Meteor
import ReactiveCocoa

//extension
extension METSubscription {
    
    var signal : RACSignal {
        let subject = RACReplaySubject()
        whenDone { (err) -> Void in
            err != nil ? subject.sendError(err) : subject.sendCompleted()
        }
        return subject
    }
}

extension METDDPClient {
    var logDDPMessages : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("METShouldLogDDPMessages")
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "METShouldLogDDPMessages")
        }
    }
    
    func loginWithFacebook(accessToken: String, expiresAt: NSDate) -> RACSignal {
        let subject = RACReplaySubject()
        let params = [["fb-access": [
            "accessToken": accessToken,
            "expireAt": expiresAt.timeIntervalSince1970
        ]]]
        loginWithMethodName("login", parameters: params) { (err) -> Void in
            err != nil ? subject.sendError(err) : subject.sendCompleted()
        }
        return subject;
    }
}
