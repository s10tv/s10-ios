//
//  MatchService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Meteor

let MatchService = MatchServiceImpl()

class MatchServiceImpl {
    
    private var meteor : METDDPClient! = nil
    private var queue : [User] = []
    private var queueUpdateSignal : RACSubject! = nil
    private(set) var currentMatch : User? = nil
    
    func startWithMeteor(meteor: METDDPClient) {
        self.meteor = meteor
        queueUpdateSignal = RACSubject()
        meteor.addSubscriptionWithName("matches")

        // TODO: What to do about the disposable here?
        NSNotificationCenter.defaultCenter()
            .rac_addObserverForName(METDatabaseDidChangeNotification, object: nil)
            .deliverOnMainThread()
            .subscribeNext { _ in
            self.updateMatchQueue()
        }
    }
    
    func getNextMatch() -> RACSignal {
        assert(NSThread.isMainThread(), "Must be on main")
        if let currentMatchId = currentMatch?.id {
            println("passing match \(currentMatchId)")
            meteor.callMethodWithName("matchPass", parameters: [currentMatchId])
            currentMatch = nil
        }
        if queue.isEmpty {
            println("Queue empty")
            return queueUpdateSignal.take(1).ignoreValues().then { self.getNextMatch() }
        } else {
            println("Queue with size \(queue.count)")
            currentMatch = queue.removeAtIndex(0)
            return RACSignal.Return(currentMatch)
        }
    }
    
    @objc func updateMatchQueue() {
        assert(NSThread.isMainThread(), "Must be on main")
        if let documents = meteor.database.collectionWithName("matches").allDocuments {
            queue.removeAll(keepCapacity: true)
            for document in documents as [METDocument] {
                let user = User.MR_createEntity() as User
                let photoURLs = document["profile"]["photos"] as? [NSString]
                user.firstName = document["profile"]["first_name"] as? String
                user.photos = photoURLs?.map { Photo(url: $0) }
                user.id = document.key.documentID as? String
                queue.append(user)
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            queueUpdateSignal.sendNext(nil)
        }
    }
}

