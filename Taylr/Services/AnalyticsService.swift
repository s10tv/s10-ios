//
//  AnalyticsService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import AnalyticsSwift
import Amplitude_iOS
import Core

class AnalyticsService {
    let env: TaylrEnvironment
    let currentUser: CurrentUser
    let segment: AnalyticsSwift.Analytics
    let amplitude: Amplitude
    
    private let cd = CompositeDisposable()

    init(env: TaylrEnvironment, currentUser: CurrentUser) {
        self.env = env
        self.currentUser = currentUser
        segment = AnalyticsSwift.Analytics.create(env.segmentWriteKey)
        amplitude = Amplitude.instance()
        amplitude.trackingSessionEvents = true
        amplitude.initializeApiKey(env.amplitudeKey)
        UXCam.startWithKey(env.uxcamKey)
        
        cd += currentUser.userId.producer.startWithNext { [weak self] userId in
            self?.identify(userId)
        }
        let propertyList = [
            "First Name": currentUser.firstName,
            "Last Name": currentUser.lastName,
            "Grad Year": currentUser.gradYear
        ]
        for (name, property) in propertyList {
            cd += property.producer.startWithNext { [weak self] value in
                if let value = value {
                    self?.setUserProperties([name: value])
                }
            }
        }
    }
    
    deinit {
        cd.dispose()
    }
    
    private func identify(userId: String?) {
        if let userId = currentUser.userId.value {
            segment.enqueue(IdentifyMessageBuilder().userId(userId))
        } else {
            segment.enqueue(IdentifyMessageBuilder().anonymousId(env.deviceId))
        }
        amplitude.setUserId(userId)
        Log.verbose("[analytics] identify \(userId)")
        flush()
    }
    
    func setUserProperties(properties: [String: AnyObject]) {
        let msg = IdentifyMessageBuilder().traits(properties)
        if let userId = currentUser.userId.value {
            segment.enqueue(msg.userId(userId))
        } else {
            segment.enqueue(msg.anonymousId(env.deviceId))
        }
        amplitude.setUserProperties(properties, replace: true)
        Log.verbose("[analytics] setUserProperties: \(properties)")
        flush()
    }
    
    func track(event: String, properties: [String: AnyObject]? = nil) {
        let msg = TrackMessageBuilder(event: event).properties(properties ?? [:])
        if let userId = currentUser.userId.value {
            segment.enqueue(msg.userId(userId))
        } else {
            segment.enqueue(msg.anonymousId(env.deviceId))
        }
        amplitude.logEvent(event, withEventProperties: properties)
        Log.verbose("[analytics] track '\(event)' properties: \(properties)")
        flush()
    }

    func screen(screenName: String, properties: [String: AnyObject]? = nil) {
        let msg = ScreenMessageBuilder(name: screenName).properties(properties ?? [:])
        if let userId = currentUser.userId.value {
            segment.enqueue(msg.userId(userId))
        } else {
            segment.enqueue(msg.anonymousId(env.deviceId))
        }
        amplitude.logEvent("Screen: \(screenName)", withEventProperties: properties)
        Log.verbose("[analytics] screen '\(screenName)' properties: \(properties)")
        flush()
    }
    
    func flush() {
        segment.flush()
        amplitude.uploadEvents()
    }
}
