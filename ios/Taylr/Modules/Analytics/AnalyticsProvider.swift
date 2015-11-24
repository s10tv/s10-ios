//
//  AnalyticsProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/23/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

@objc protocol AnalyticsProvider : class {
    // Identity Management
    func identifyUser(userId: String)
    optional func identifyDevice(deviceId: String)
    optional func setUserProperties(properties: [String: AnyObject])
    optional func incrementUserProperty(propertyName: String, amount: NSNumber)

    // Event management
    func track(event: String!, properties: [NSObject : AnyObject]?)
    optional func registerSuperproperties(properties: [String: AnyObject])
    
    // Push Notification
    optional func addPushDeviceToken(deviceToken: NSData)
    optional func trackPushNotification(userInfo: [NSObject : AnyObject])
    
    // Utils
    optional func reset()
    optional func flush()
}