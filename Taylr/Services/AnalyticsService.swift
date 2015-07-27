//
//  AnalyticsService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import AnalyticsSwift
import Core
import Appsee
//import Heap

class AnalyticsService {
    private(set) var userId: String?
    let segment: AnalyticsSwift.Analytics

    init(env: TaylrEnvironment) {
        // Segmentio
        segment = AnalyticsSwift.Analytics.create(env.segmentWriteKey)
        Appsee.start(env.appseeApiKey)
        
//        // Heap
//        Heap.setAppId(env.heapAppId)
//        if env.audience == .Dev {
//            Heap.enableVisualizer()
//        }
        
        // Set initial userId
        if let meteorUserId = UD[.sMeteorUserId].string {
            identifyUser(meteorUserId)
        } else {
            identifyUser(env.deviceId)
        }
    }
    
    private func identify(userId: String?, traits: [String: AnyObject]? = nil) {
        self.userId = userId
        Appsee.setUserID(userId)
        // Send traits up to our own backend server
        if let traits = traits {
            for (key, value) in traits {
                // TODO: Put stuff into Meteor.meta as needed
                // or some other channel that's easily viewable from server
//                Meteor.meta.setValue(value, metadataKey: key)
            }
        }
        segment.enqueue(IdentifyMessageBuilder().traits(traits ?? [:]).userId(userId ?? ""))
        segment.flush()
        Log.verbose("[analytics] identify \(userId) traits: \(traits)")
    }
    
    func track(event: String, properties: [String: AnyObject]? = nil) {
        segment.enqueue(TrackMessageBuilder(event: event).properties(properties ?? [:]).userId(userId ?? ""))
        segment.flush()
        Log.verbose("[analytics] track '\(event)' properties: \(properties)")
    }
}

// MARK: - Explicit Identity Management

extension AnalyticsService {
    
    // TODO: Add alias support
    func identifyUser(userId: String) {
        identify(userId)
    }
    
    func identifyTraits(traits: [String: AnyObject]) {
        identify(userId, traits: traits)
    }
}
