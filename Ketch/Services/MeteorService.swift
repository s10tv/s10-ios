//
//  MeteorService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/10/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SugarRecord
import Meteor

class MeteorService : NSObject {
    /*private*/ let meteor: METCoreDataDDPClient
    let subscriptions: (
        metadata: METSubscription,
        currentUser: METSubscription,
        candidates: METSubscription,
        connections: METSubscription,
        messages: METSubscription
    )
    let collections: (
        metadata: METCollection,
        users: METCollection,
        candidates: METCollection,
        connections: METCollection,
        messages: METCollection
    )
    
    // Proxied accessors
    var connectionStatus: METDDPConnectionStatus { return meteor.connectionStatus }
    var connected: Bool { return meteor.connected }
    var loggingIn: Bool { return meteor.loggingIn }
    var account: METAccount? { return meteor.account }
    weak var delegate: METDDPClientDelegate? {
        get { return meteor.delegate }
        set { meteor.delegate = newValue }
    }
    
    init(serverURL: NSURL) {
        let account = METAccount.defaultAccount()
        meteor = METCoreDataDDPClient(serverURL: serverURL, account: account)
        subscriptions = (
            meteor.addSubscriptionWithName("metadata"),
            meteor.addSubscriptionWithName("currentUser"),
            meteor.addSubscriptionWithName("candidates"),
            meteor.addSubscriptionWithName("connections"),
            meteor.addSubscriptionWithName("messages")
        )
        collections = (
            meteor.database.collectionWithName("metadata"),
            meteor.database.collectionWithName("users"),
            meteor.database.collectionWithName("candidates"),
            meteor.database.collectionWithName("connections"),
            meteor.database.collectionWithName("messages")
        )
        
        METSubscription(identifier: "currentUser", name: nil, parameters: nil)
        
        super.init()
    }
    
}
