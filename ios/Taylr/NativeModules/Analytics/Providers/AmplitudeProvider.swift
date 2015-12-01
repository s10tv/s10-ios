//
//  AmplitudeProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Amplitude_iOS
import CocoaLumberjack

public class AmplitudeProvider : BaseAnalyticsProvider {
    
    let amplitude = Amplitude.instance()
    
    init(apiKey: String) {
        amplitude.initializeApiKey(apiKey)
        amplitude.trackingSessionEvents = true
    }
    
    func updateIdentity() {
        DDLogInfo("Will update identity userId=\(context.userId) deviceId=\(context.deviceId)")
        amplitude.setUserId(context.userId)
        amplitude.setDeviceId(context.deviceId)
        setUserProperties(["Device Name": context.deviceName])
    }
    
    override func launch(currentBuild: String, previousBuild: String?) {
        updateIdentity()
        super.launch(currentBuild, previousBuild: previousBuild)
        amplitude.uploadEvents()
        DDLogInfo("Did Launch and upload events")
    }
    
    override func login(isNewUser: Bool) {
        updateIdentity()
        super.login(isNewUser)
        amplitude.uploadEvents()
        DDLogInfo("Did Login and upload events")
    }
    
    override func logout() {
        super.logout()
        updateIdentity()
        amplitude.uploadEvents()
        DDLogInfo("Did Logout and upload events")
    }
    
    override func setUserProperties(properties: [NSObject : AnyObject]) {
        DDLogDebug("Will set user properties", tag: properties)
        amplitude.setUserProperties(properties)
    }
    
    override func track(event: String, properties: [NSObject : AnyObject]? = nil) {
        DDLogDebug("Will log event event=\(event)", tag: properties)
        amplitude.logEvent(event, withEventProperties: properties)
    }
}
