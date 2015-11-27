//
//  AmplitudeProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Amplitude_iOS

public class AmplitudeProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!
    
    let amplitude = Amplitude.instance()
    
    init(apiKey: String) {
        amplitude.initializeApiKey(apiKey)
        amplitude.trackingSessionEvents = true
    }
    
    func appInstall() {
        amplitude.setDeviceId(context.deviceId)
        setUserProperties(["Device Name": context.deviceName])
    }
    
    func login(isNewUser: Bool) {
        amplitude.setUserId(context.userId)
        track("Login", properties: ["New User": isNewUser])
        updateUsername()
        updateEmail()
        updateFullname()
        updatePhone()
    }
    
    func logout() {
        amplitude.logEvent("Logout")
        amplitude.setUserId(nil)
    }
    
    func setUserProperties(properties: [NSObject : AnyObject]) {
        amplitude.setUserProperties(properties)
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        amplitude.logEvent(event, withEventProperties: properties)
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]?) {
        amplitude.logEvent(name, withEventProperties: properties)
    }
    
    
}
