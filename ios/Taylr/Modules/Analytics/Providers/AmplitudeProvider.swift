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
        amplitude.setUserId(context.userId)
        amplitude.setDeviceId(context.deviceId)
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
    
    override func setUserProperties(properties: [NSObject : AnyObject]) {
        amplitude.setUserProperties(properties)
    }
    
    override func track(event: String, properties: [NSObject : AnyObject]? = nil) {
        amplitude.logEvent(event, withEventProperties: properties)
    }
}
