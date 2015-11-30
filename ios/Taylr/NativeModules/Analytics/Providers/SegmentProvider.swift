//
//  SegmentProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import AnalyticsSwift
import CocoaLumberjack

public class SegmentProvider : BaseAnalyticsProvider {
    
    let segment: AnalyticsSwift.Analytics
    
    init(writeKey: String) {
        segment = AnalyticsSwift.Analytics.create(writeKey)
    }
    
    // MARK: -
    
    func updateIdentity() {
        if let userId = context.userId {
            segment.enqueue(IdentifyMessageBuilder().anonymousId(userId))
        } else {
            segment.enqueue(IdentifyMessageBuilder().anonymousId(context.deviceId))
        }
        setUserProperties(["Device Name": context.deviceName])
    }
    
    override func launch(currentBuild: String, previousBuild: String?) {
        updateIdentity()
        super.launch(currentBuild, previousBuild: previousBuild)
        DDLogInfo("Did Login")
    }
    
    override func login(isNewUser: Bool) {
        updateIdentity()
        super.login(isNewUser)
        DDLogInfo("Did Login")
    }
    
    override func logout() {
        super.logout()
        updateIdentity()
        DDLogInfo("Did Logout")
    }
    
    override func track(event: String, properties: [NSObject : AnyObject]?) {
        var msg = TrackMessageBuilder(event: event).properties(convertProperties(properties))
        msg = context.userId.map { msg.userId($0) } ?? msg.anonymousId(context.deviceId)
        segment.enqueue(msg)
    }
    
    override func screen(name: String, properties: [NSObject : AnyObject]?) {
        var msg = ScreenMessageBuilder(name: name).properties(convertProperties(properties))
        msg = context.userId.map { msg.userId($0) } ?? msg.anonymousId(context.deviceId)
        segment.enqueue(msg)
    }
    
    override func setUserProperties(properties: [NSObject : AnyObject]) {
        var msg = IdentifyMessageBuilder().traits(convertProperties(properties))
        msg = context.userId.map { msg.userId($0) } ?? msg.anonymousId(context.deviceId)
        segment.enqueue(msg)
    }
}
