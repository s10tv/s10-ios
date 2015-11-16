//
//  TaylrAPI.swift
//  S10
//
//  Created by Tony Xiao on 11/2/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import React
import Core

@objc(TaylrAPI)
class TaylrAPI : NSObject {
    
    @objc weak var bridge: RCTBridge?
    
    @objc func getMeteorUser(callback: RCTResponseSenderBlock) {
        if let account = MainContext.meteor.account.value {
            Log.info("Will return meteor account to JS \(account.userID) token \(account.resumeToken)")
            callback([account.userID, account.resumeToken])
        } else {
            Log.info("Will return nil meteor account to JS")
            callback([])
        }
        bridge?.eventDispatcher.sendAppEventWithName("Example", body: ["Example": "Data"])
    }
}