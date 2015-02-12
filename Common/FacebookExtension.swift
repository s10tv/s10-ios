//
//  FacebookExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/11/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import FacebookSDK
import ReactiveCocoa

extension FBSession {
    
    // Open without UI
    class func openActiveSession(#readPermissions: [String]) -> Bool {
        return openActiveSessionWithReadPermissions(readPermissions, allowLoginUI: false, completionHandler: nil)
    }

    class func openActiveSessionWithUI(#readPermissions: [String]) -> RACSignal {
        let subject = RACReplaySubject()
        let opened = openActiveSessionWithReadPermissions(readPermissions, allowLoginUI: true) { (session, state, error) -> Void in
            switch state {
            case .Open, .OpenTokenExtended:
                subject.sendCompleted()
            case .ClosedLoginFailed:
                subject.sendError(error)
            default:
                break
            }
        }
        if opened {
            subject.sendCompleted()
        }
        return subject
    }
}
