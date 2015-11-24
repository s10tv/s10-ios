//
//  Analytics.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Intercom

public let Analytics = TSAnalytics()

@objc(TSAnalytics)
public class TSAnalytics : NSObject {
    var providers: [AnalyticsProvider] = []
    
    func setup(config: AppConfig, launchOptions: [NSObject: AnyObject]?) {
        providers = [
            AmplitudeProvider(apiKey: config.amplitudeKey),
            MixpanelProvider(apiToken: config.mixpanelToken, launchOptions: launchOptions),
            IntercomProvider(appId: config.intercom.appId, apiKey: config.intercom.apiKey),
            SegmentProvider(writeKey: config.segmentWriteKey),
            UXCamProvider(apiKey: config.uxcamKey),
        ]
        DDLogInfo("Did setup providers with config \(config) launchOptions \(launchOptions)")
    }
    
    @objc func identify(userId: String) {
        for provider in providers {
            provider.identifyUser(userId)
        }
        DDLogInfo("Identify userId=\(userId)")
    }
    
    @objc func track(event: String, properties: [String: AnyObject]? = nil) {
        for provider in providers {
            provider.track(event, properties: properties)
        }
        DDLogDebug("Track event=\(event) properties=\(properties)")
    }
    
    @objc func setUserProperties(properties: [String: AnyObject]? = nil) {
        guard let properties = properties else {
            return
        }
        for provider in providers {
            provider.setUserProperties?(properties)
        }
        DDLogDebug("Set user properties=\(properties)")
    }
    
    @objc func incrementUserProperty(propertyName: String, amount: NSNumber) {
        for provider in providers {
            provider.incrementUserProperty?(propertyName, amount: amount)
        }
        DDLogDebug("Increment user property name=\(propertyName) amount=\(amount)")
    }
    
    @objc func intercomPresentMessageComposer() {
        dispatch_async(dispatch_get_main_queue()) {
            Intercom.presentMessageComposer()
        }
    }
    
    @objc func intercomPresentConversationList() {
        dispatch_async(dispatch_get_main_queue()) {
            Intercom.presentConversationList()
        }
    }
}
