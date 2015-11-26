//
//  Analytics.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack

public let Analytics = TSAnalytics()

@objc(TSAnalytics)
public class TSAnalytics : NSObject {
    var providers: [AnalyticsProvider] = []

    @objc func identifyDevice(deviceId: String) {
        for provider in providers {
            provider.identifyDevice?(deviceId)
        }
        DDLogInfo("Identify deviceId=\(deviceId)")
    }
    
    @objc func identifyUser(userId: String) {
        for provider in providers {
            provider.identifyUser?(userId)
        }
        DDLogInfo("Identify userId=\(userId)")
    }
    
    @objc func setUserPhone(phone: String) {
        for provider in providers {
            provider.setUserPhone?(phone)
        }
        DDLogInfo("setUserPhone phone=\(phone)")
    }
    
    @objc func setUserEmail(email: String) {
        for provider in providers {
            provider.setUserEmail?(email)
        }
        DDLogInfo("setUserEmail email=\(email)")
    }
    
    @objc func setUserFullname(fullname: String) {
        for provider in providers {
            provider.setUserFullname?(fullname)
        }
        DDLogInfo("setUserFullName fullname=\(fullname)")
    }
    
    @objc func track(event: String, properties: [String: AnyObject]? = nil) {
        for provider in providers {
            provider.track?(event, properties: properties)
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
    

}
