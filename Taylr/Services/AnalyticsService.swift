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
import Mixpanel
import Core

class AnalyticsService {
    private let env: TaylrEnvironment
    private let currentUser: CurrentUser
    private let segment: AnalyticsSwift.Analytics
    private let amplitude: Amplitude
    private let mixpanel: Mixpanel

    private let cd = CompositeDisposable()

    init(env: TaylrEnvironment, currentUser: CurrentUser) {
        self.env = env
        self.currentUser = currentUser
        segment = AnalyticsSwift.Analytics.create(env.segmentWriteKey)
        amplitude = Amplitude.instance()
        amplitude.trackingSessionEvents = true
        amplitude.initializeApiKey(env.amplitudeKey)
        mixpanel = Mixpanel.sharedInstanceWithToken(env.mixpanelToken)
//        UXCam.startWithKey(env.uxcamKey)

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
            mixpanel.identify(userId)
            amplitude.setUserId(userId)
        } else {
            segment.enqueue(IdentifyMessageBuilder().anonymousId(env.deviceId))
            mixpanel.identify(env.deviceId)
            amplitude.setUserId(nil)
        }
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
        // Only track properties to mixpanel post-digits login
        if let userId = currentUser.userId.value where userId == mixpanel.distinctId {
            var props = properties
            props["$first_name"] = props.removeValueForKey("First Name")
            props["$last_name"] = props.removeValueForKey("Last Name")
            mixpanel.people.set(props)
        }
        flush()
    }

    func track(event: String, _ properties: [String: AnyObject]? = nil) {
        let msg = TrackMessageBuilder(event: event).properties(properties ?? [:])
        if let userId = currentUser.userId.value {
            segment.enqueue(msg.userId(userId))
        } else {
            segment.enqueue(msg.anonymousId(env.deviceId))
        }
        amplitude.logEvent(event, withEventProperties: properties)
        // Only track events to mixpanel post-digits login
        if let userId = currentUser.userId.value where userId == mixpanel.distinctId {
            mixpanel.track(event, properties: properties)
        }
        Log.verbose("[analytics] track '\(event)' properties: \(properties)")
        flush()
    }

    func flush() {
        segment.flush()
        amplitude.uploadEvents()
        mixpanel.flush()
    }
}
