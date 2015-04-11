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
    
    class func openActiveSession(#readPermissions: [String], allowLoginUI: Bool = false) -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable in
            let opened = FBSession.openActiveSessionWithReadPermissions(readPermissions, allowLoginUI: allowLoginUI) { (session, state, error) -> Void in
                switch state {
                case .Open, .OpenTokenExtended:
                    subscriber.sendCompleted()
                case .ClosedLoginFailed:
                    subscriber.sendError(error)
                default:
                    assert(false, "Unexpected FBSession state received while loggin in \(state)")
                    break
                }
            }
            if opened {
                subscriber.sendCompleted()
            }
            return RACDisposable(block: {
                FBSession.activeSession().setStateChangeHandler({ _, _, _ in })
            })
        }.replayWithSubject()
    }
}
