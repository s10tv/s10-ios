//
//  MatchService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

class MatchService {
    private let meteor : METCoreDataDDPClient
    private let subscription : METSubscription
    private let fetch : FetchViewModel
    
    let currentMatch = RACReplaySubject(capacity: 1)
    
    init(meteor: METCoreDataDDPClient) {
        self.meteor = meteor
        subscription = meteor.addSubscriptionWithName("matches")
        fetch = FetchViewModel(frc:
            Match.MR_fetchAllSortedBy(MatchAttributes.dateMatched.rawValue, ascending: true,
                withPredicate: nil, groupBy: nil, delegate: nil))

        // Define Stub method
        meteor.defineStubForMethodWithName("matchPass", usingBlock: { (args) -> AnyObject! in
            let match = Match.findByDocumentID((args as [String]).first!)
            match?.MR_deleteEntity()
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

