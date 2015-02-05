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
            println("Queue size \(queue.count)")
            currentMatch = queue.removeAtIndex(0)
            println("Will return match \(currentMatch?.id)")
            return RACSignal.Return(currentMatch)
        }
    }
    
    @objc func updateMatchQueue() {
        assert(NSThread.isMainThread(), "Must be on main")
        if let documents = meteor.database.collectionWithName("matches").allDocuments {
            queue.removeAll(keepCapacity: true)
            for document in documents as [METDocument] {
                let age = (19...28).map { $0 }.randomElement()
                let location = [
                    "San Francisco, CA",
                    "Mountain View, CA",
                    "Palo Alto, CA",
                    "Menlo Park, CA",
                    "Sausalito, CA",
                    "San Mateo, CA",
                    "Cupertino, CA",
                    "Sunnyvale, CA",
                    "Berkeley, CA"
                ].randomElement()
                let photoURLs = document["profile"]["photos"] as? [NSString]
                let user = User.MR_createEntity() as User
                user.id = document.key.documentID as? String
                user.firstName = document["profile"]["first_name"] as? String
                user.work = document["profile"]["work"] as? String
                user.education = document["profile"]["education"] as? String
                user.about = document["profile"]["about"] as? String
                user.photos = photoURLs?.map { Photo(url: $0) }
                user.age = age // Hack for now
                user.location = location // Hack for now
                queue.append(user)
            }
            println("Updated queue with new size \(queue.count) \(queue.map { $0.firstName! })")
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            queueUpdateSignal.sendNext(nil)
        }
    }
}

