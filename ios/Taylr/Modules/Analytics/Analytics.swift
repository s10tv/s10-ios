//
//  Analytics.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ARAnalytics
import Amplitude_iOS
#if ReleaseConfig
import UXCam
#endif

@objc(TSAnalytics)
public class Analytics : NSObject {
    
    init(config: AppConfig) {
        super.init()
        Amplitude.instance().trackingSessionEvents = true
        ARAnalytics.setupMixpanelWithToken(config.mixpanelToken)
        ARAnalytics.setupAmplitudeWithAPIKey(config.amplitudeKey)
        ARAnalytics.setupSegmentioWithWriteKey(config.segmentWriteKey)
        ARAnalytics.setupProvider(LoggingProvider())
        #if ReleaseConfig
        if config.audience != .Dev {
            UXCam.startWithKey(config.uxcamKey)
        }
        #endif
    }
    
    @objc func identify(userId: String) {
        ARAnalytics.identifyUserWithID(userId, andEmailAddress: nil)
    }
    
    @objc func track(event: String, properties: [String: AnyObject]? = nil) {
        ARAnalytics.event(event, withProperties: properties)
    }
    
    @objc func setUserProperty(name: String, value: String?) {
        ARAnalytics.setUserProperty(name, toValue: value)
    }
    
    @objc func incrementUserProperty(name: String, amount: Int) {
        ARAnalytics.incrementUserProperty(name, byInt: amount)
    }
}
