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

class CandidateService {
    private let meteor : METCoreDataDDPClient
//    private let subscription : METSubscription
    let fetch : FetchViewModel
    
    init(meteor: METCoreDataDDPClient) {
        self.meteor = meteor
        let frc = Candidate.by(CandidateAttributes.choice.rawValue, value: nil).sorted(by: CandidateAttributes.createdAt.rawValue, ascending: true).frc()
        fetch = FetchViewModel(frc: frc)

        // Define Stub method
        meteor.defineStubForMethodWithName("candidate/submitChoices", usingBlock: { (args) -> AnyObject! in
            assert(NSThread.isMainThread(), "Only main supported for now")
            for (choice, candidateId) in (args.first as [String: String]) {
                if let candidate = Candidate.findByDocumentID(candidateId) {
                    candidate.delete()
                }
            }
            return true
        })
//        
//        // TODO: Tear down these subscriptions on deinit
//        subscription.signal.deliverOnMainThread().subscribeCompleted {
//            self.fetch.performFetchIfNeeded()
//        }
//        fetch.signal.subscribeNextAs { (candidates : [Candidate]) in
//            NC.postNotification(.CandidatesUpdated, object: candidates)
//        }
    }
    
    func submitChoices(#yes: Candidate, no: Candidate, maybe: Candidate) {
        NC.postNotification(.DidSubmitGame, object: self)
        meteor.callMethod("candidate/submitChoices", params: [[
            "yes": yes.documentID!,
            "no": no.documentID!,
            "maybe": maybe.documentID!
        ]]).deliverOnMainThread().subscribeNextAs { (res : [NSObject : AnyObject]) in
            NC.postNotification(.DidReceiveGameResult, object: self, userInfo: res)
        }
    }
}

