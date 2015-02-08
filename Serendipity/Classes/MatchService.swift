//
//  MatchService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor
import SugarRecord

class MatchService {
    private let meteor : METCoreDataDDPClient
    private let subscription : METSubscription
    private let fetch : FetchViewModel
    
    let currentMatch = RACReplaySubject(capacity: 1)
    
    init(meteor: METCoreDataDDPClient) {
        self.meteor = meteor
        subscription = meteor.addSubscriptionWithName("matches")
        let frc = Match.all().sorted(by: MatchAttributes.dateMatched.rawValue, ascending: true).frc()
        fetch = FetchViewModel(frc: frc)

        // Define Stub method
        meteor.defineStubForMethodWithName("matchPass", usingBlock: { (args) -> AnyObject! in
            assert(NSThread.isMainThread(), "Only main supported for now")
            if let match = Match.findByDocumentID((args as [String]).first!) {
                match.beginWriting()
                match.delete()
                match.endWriting()
            }
            return true
        })
        
        // Setup the currentMatch signal (TODO: memory mgmt)
        subscription.signal.deliverOnMainThread().then {
            self.fetch.performFetchIfNeeded()
            return self.fetch.signal
        }.map { (mmatches) -> AnyObject! in
            return (mmatches as [Match]).first
        }.subscribe(currentMatch)
    }
    
    func passMatch(match: Match) {
        meteor.callMethodWithName("matchPass", parameters: [match.documentID!])
    }
}

