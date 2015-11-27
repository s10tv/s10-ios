//
//  AmplitudeProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Amplitude_iOS

public class AmplitudeProvider : BaseAnalyticsProvider {
    
    let amplitude = Amplitude.instance()
    
    init(apiKey: String) {
        amplitude.initializeApiKey(apiKey)
        amplitude.trackingSessionEvents = true
    }
    
    override func updateIdentity() {
        amplitude.setUserId(context.userId)
        amplitude.setDeviceId(context.deviceId)
        setUserProperties(["Device Name": context.deviceName])
    }
    
    override func setUserProperties(properties: [NSObject : AnyObject]) {
        amplitude.setUserProperties(properties)
    }
    
    override func track(event: String, properties: [NSObject : AnyObject]? = nil) {
        amplitude.logEvent(event, withEventProperties: properties)
    }
}
