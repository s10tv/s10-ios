//
//  SegmentProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import AnalyticsSwift


public class SegmentProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!
    
    let segment: AnalyticsSwift.Analytics
    
    init(writeKey: String) {
        segment = AnalyticsSwift.Analytics.create(writeKey)
    }
    
    // MARK: -
    
    func appInstall() {
        segment.enqueue(IdentifyMessageBuilder().anonymousId(context.deviceId))
        setUserProperties(["Device Name": context.deviceName])
    }
    
    func appOpen() {
        track("App: Open", properties: nil)
    }
    
    func appClose() {
        track("App: Close", properties: nil)
    }
    
    func login(isNewUser: Bool) {
        guard let userId = context.userId else { return }
        segment.enqueue(IdentifyMessageBuilder().userId(userId))
        track("Login", properties: ["New User": isNewUser])
    }
    
    func logout() {
        track("Logout", properties: nil)
        segment.enqueue(IdentifyMessageBuilder().anonymousId(context.deviceId))
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        var msg = TrackMessageBuilder(event: event).properties(convertProperties(properties))
        msg = context.userId.map { msg.userId($0) } ?? msg.anonymousId(context.deviceId)
        segment.enqueue(msg)
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]?) {
        var msg = ScreenMessageBuilder(name: name).properties(convertProperties(properties))
        msg = context.userId.map { msg.userId($0) } ?? msg.anonymousId(context.deviceId)
        segment.enqueue(msg)
    }
    
    func setUserProperties(properties: [NSObject : AnyObject]) {
        var msg = IdentifyMessageBuilder().traits(convertProperties(properties))
        msg = context.userId.map { msg.userId($0) } ?? msg.anonymousId(context.deviceId)
        segment.enqueue(msg)
    }
}
