//
//  AnalyticsService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Analytics
import Core
//import Heap

class AnalyticsService {
    private(set) var userId: String?
    let segment: SEGAnalytics

    init(env: TaylrEnvironment) {
        // Segmentio
        let config = SEGAnalyticsConfiguration(writeKey: env.segmentWriteKey)
        config.enableAdvertisingTracking = false // Don't get into trouble with app store for now
        SEGAnalytics.setupWithConfiguration(config)
        segment = SEGAnalytics.sharedAnalytics()
        
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
        // Send traits up to our own backend server
        if let traits = traits {
            for (key, value) in traits {
                Meteor.meta.setValue(value, metadataKey: key)
            }
        }
        segment.identify(userId, traits: traits)
        segment.flush()
        Log.verbose("[analytics] identify \(userId) traits: \(traits)")
    }
    
    func track(event: String, properties: [String: AnyObject]? = nil) {
        segment.track(event, properties: properties)
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
