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
        track("App: Install", properties: nil)
    }
    
    func appOpen() {
        track("App: Open", properties: nil)
    }
    
    func appClose() {
        track("App: Close", properties: nil)
    }
    
    func login(isNewUser: Bool) {
        amplitude.setUserId(context.userId)
        track("Login", properties: ["New User": isNewUser])
    }
    
    func logout() {
        track("Logout", properties: nil)
        amplitude.setUserId(nil)
    }
    
    func setUserProperties(properties: [NSObject : AnyObject]) {
        amplitude.setUserProperties(properties)
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        amplitude.logEvent(event, withEventProperties: properties)
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]?) {
        amplitude.logEvent("Screen: \(name)", withEventProperties: properties)
    }
}
