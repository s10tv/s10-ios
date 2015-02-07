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
    
    private var meteor : METCoreDataDDPClient! = nil
    private var matches : [Match] = []
    private var queueUpdateSignal : RACSubject! = nil
    private(set) var currentMatch : Match? = nil
    
    func startWithMeteor(meteor: METCoreDataDDPClient) {
        self.meteor = meteor
        queueUpdateSignal = RACSubject()

        meteor.addSubscriptionWithName("matches").signal.deliverOnMainThread().subscribeCompleted {
            self.reloadMatches()
            // TODO: What to do about the disposable here?
            NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(METDatabaseDidChangeNotification, object: nil)
                .deliverOnMainThread()
                .subscribeNextAs { (notification: NSNotification) -> () in
                    self.handleDatabaseChange(notification)
            }
        }
        
        meteor.defineStubForMethodWithName("matchPass", usingBlock: { (args) -> AnyObject! in
            let user = User.findByDocumentID((args as [String]).first!)
            user?.match?.MR_deleteEntity()
            return true
        })
    }
    
    func handleDatabaseChange(databaseChangeNotification: NSNotification) {
        let users = User.MR_findAll() as? [User]
        let userDocs = meteor.database.collectionWithName("users").allDocuments
        println("users \(users?.count) docs \(userDocs?.count) \(userDocs)")
        if let user = users?.first {
            println(user.createdAt)
        }
        
        let changes = databaseChangeNotification.userInfo![METDatabaseChangesKey] as METDatabaseChanges
        var changed = false
        for key in changes.affectedDocumentKeys().allObjects as [METDocumentKey] {
            if key.collectionName == "matches" {
                changed = true
                break
            }
        }
        if changed {
            reloadMatches()
        }
    }
    
    func reloadMatches() {
        self.matches = Match.MR_findAll() as [Match]
        self.queueUpdateSignal.sendNext(nil)
    }
    
    func getNextMatch() -> RACSignal {
        assert(NSThread.isMainThread(), "Must be on main")
        if let currentMatchUser = currentMatch?.user {
            let key = meteor.documentKeyForObjectID(currentMatchUser.objectID)
            println("passing match \(key)")
            meteor.callMethodWithName("matchPass", parameters: [key.documentID])
            currentMatch = nil
        }
        if matches.isEmpty {
            println("Queue empty")
            return queueUpdateSignal.take(1).ignoreValues().then { self.getNextMatch() }
        } else {
            println("Queue size \(matches.count)")
            currentMatch = matches.removeAtIndex(0)
            println("Will return match \(currentMatch?.user)")
            return RACSignal.Return(currentMatch)
        }
    }
    
}

