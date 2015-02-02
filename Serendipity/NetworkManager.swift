//
//  NetworkManager.swift
//  Serendipity
//
//  Created by Qiming Fang on 2/1/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ObjectiveDDP

class NetworkManager : NSObject {
    var meteor: MeteorClient!

    /**
     * Sets up Network Manager by initializing the objective DDP stack.
     */
    required init(wsAddress: String) {
        meteor = MeteorClient(DDPVersion: "1")
        meteor.ddp = ObjectiveDDP(URLString: wsAddress, delegate: meteor)
        meteor.ddp.connectWebSocket()
    }
    
    func startPubsub() {
        // notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection",
            name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection",
            name: MeteorClientDidDisconnectNotification, object: nil)
        
        // subscribe to "the allUsers" call, which populates the users collection.
        meteor.addSubscription("allUsers");
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            "didReceiveUpdate:", name: "users_added", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            "didReceiveUpdate:", name: "users_removed", object: nil)
    }
    
    func reportConnection() {
        println("================> connected to server!")
    }
    
    func reportDisconnection() {
        println("================> disconnected from server!")
    }
    
    func didReceiveUpdate(notification:NSNotification) {
        println("Received Data");
    }
    
    /**
     * Logs in to meteor server with
     *
     * @param userParameters: [{ "accessToken" : token, "expireAt" : expireAt }]
     * @param responseCallback: ([NSObject : AnyObject]!, NSError!) -> Void
     */
    func logIn(userParameters: [NSObject : AnyObject]!,
        responseCallback:MeteorClientMethodCallback) {
        self.meteor.logonWithUserParameters(userParameters, responseCallback);
    }
}