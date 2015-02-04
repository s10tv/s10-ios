//
//  CoreService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/3/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import CoreData
import FacebookSDK
import MagicalRecord
import ReactiveCocoa
import Meteor

class CoreService {
    
    let meteor : METDDPClient
    
    init() {
        let urlStr = "ws://s10.herokuapp.com/websocket"
//        let urlStr = "ws://localhost:3000/websocket"
        meteor = METDDPClient(serverURL: NSURL(string: urlStr))
        setupCoreData()
        setupMeteor()
    }
    
    private func setupCoreData() {
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }
    
    private func setupMeteor() {
        // TODO: Need to connect after authenticating with fb, not just at app start
        if FBSession.openActiveSessionWithAllowLoginUI(false) {
            let data = FBSession.activeSession().accessTokenData
            let userParam = [["fb-access": [
                "accessToken": data.accessToken,
                "expireAt": data.expirationDate.timeIntervalSince1970
            ]]]
            meteor.loginWithMethodName("login", parameters: userParam, completionHandler: { err in
                println("Logged in with error? \(err)")
            })
        }
        MatchService.startWithMeteor(meteor)
    }
}