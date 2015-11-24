//
//  MixpanelProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Mixpanel

public class MixpanelProvider : NSObject, AnalyticsProvider {
    
    let mixpanel: Mixpanel
    
    init(apiToken: String, launchOptions: [NSObject: AnyObject]?) {
        mixpanel = Mixpanel.sharedInstanceWithToken(apiToken, launchOptions: launchOptions)
    }
    
    func identifyUser(userId: String) {
        mixpanel.identify(userId)
    }
    
    func track(event: String!, properties: [NSObject : AnyObject]?) {
        mixpanel.track(event, properties: properties)
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
        mixpanel.people.set(properties)
    }
}
