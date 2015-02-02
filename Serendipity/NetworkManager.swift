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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onConnect",
            name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDisconnect",
            name: MeteorClientDidDisconnectNotification, object: nil)
    }
    
    /**
     * Handler for when the server connection is established.
     * Sets up subscribers for topics and event handlers.
     */
    func onConnect() {
        // handles updates to current user.
        meteor.addSubscription("userData");
      
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            "onAddUser:", name: "users_added", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            "onChangeUser:", name: "users_changed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            "onRemoveUser:", name: "users_removed", object: nil)
    }
    
    /**
     * Handler for when the server connection is destroyed.
     */
    func onDisconnect() {
        println("================> disconnected from server!")
    }
    
    /**
     * Handler for user add notification.
     */
    func onAddUser(notification : NSNotification) {
        var ddpUser : NSDictionary = notification.userInfo! as NSDictionary
        var user: User = User.create() as User
        user = parseUser(ddpUser, user: user);
        user.save()
    }
    
    func onChangeUser(notification: NSNotification) {
        var ddpUser : NSDictionary = notification.userInfo! as NSDictionary
        var user: User = User.all().find().firstObject() as User
        user = parseUser(ddpUser, user: user);
        
        println(user.matchFirstName!)
    }
    
    func onRemoveUser(notification : NSNotification) {
        println("Received Remove User");
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
    
    // TODO(qimingfang): there has to be a better way to do this.
    func parseUser(ddpUser: NSDictionary, user : User) -> User {
        user.beginWriting()
        user.id = ddpUser["_id"]! as NSString
        
        var profile : NSDictionary = ddpUser["profile"]! as NSDictionary
        user.firstName = profile["first_name"]! as NSString
        
        var userPhotos : [NSString] = profile["photos"]! as [NSString]
        var photos : [Photo] = Array<Photo>()
        for userPhoto in userPhotos {
            photos.append(Photo(url: userPhoto))
        }
        user.photos = photos
        
        // TODO(qimingfang): there has to be a better way to do this.
        if (ddpUser["currentMatch"] != nil){
            var currentMatch = ddpUser["currentMatch"]! as NSDictionary
            var currentMatchProfile : NSDictionary = currentMatch["profile"]! as NSDictionary
            user.matchFirstName = currentMatchProfile["first_name"]! as NSString
            
            var currentMatchPhotos : [NSString] = currentMatchProfile["photos"]! as [NSString]
            var savedCurrentMatchPhotos : [Photo] = Array<Photo>()
            for currentMatchPhoto in currentMatchPhotos {
                savedCurrentMatchPhotos.append(Photo(url: currentMatchPhoto))
            }
            user.matchPhotos = savedCurrentMatchPhotos
        }
        
        user.endWriting()
        return user
    }
}