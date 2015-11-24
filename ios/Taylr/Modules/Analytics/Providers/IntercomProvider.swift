//
//  IntercomProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Intercom

public class IntercomProvider : NSObject, AnalyticsProvider {
    
    init(appId: String, apiKey: String) {
        Intercom.setApiKey(apiKey, forAppId: appId)
        Intercom.setPreviewPosition(.BottomRight)
    }
    
    func identifyUser(userId: String) {
        Intercom.registerUserWithUserId(userId)
    }
    
    func track(event: String!, properties: [NSObject : AnyObject]?) {
        if let properties = properties {
            Intercom.logEventWithName(event, metaData: properties)
        } else {
            Intercom.logEventWithName(event)
        }
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
        Intercom.updateUserWithAttributes(["custom_attributes": properties])
    }
}
