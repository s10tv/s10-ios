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

    let amplitude = Amplitude.instance()
    
    init(apiKey: String) {
        amplitude.initializeApiKey(apiKey)
        amplitude.trackingSessionEvents = true
    }
    
    func identifyUser(userId: String) {
        amplitude.setUserId(userId)
    }
    
    func track(event: String!, properties: [NSObject : AnyObject]?) {
        amplitude.logEvent(event, withEventProperties: properties)
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
        amplitude.setUserProperties(properties)
    }
}
