//
//  IntercomProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Intercom
import ARAnalytics

public class IntercomProvider : ARAnalyticalProvider {
    
    init(appId: String, apiKey: String) {
        Intercom.setApiKey(apiKey, forAppId: appId)
        Intercom.setPreviewPosition(.BottomRight)
        super.init(identifier: appId)
    }
    
    public override func identifyUserWithID(userID: String!, andEmailAddress email: String!) {
        if let userID = userID {
            Intercom.registerUserWithUserId(userID)
        }
    }
    
    public override func event(event: String!, withProperties properties: [NSObject : AnyObject]!) {
        Intercom.logEventWithName(event, metaData: properties)
    }
    
    public override func setUserProperty(property: String!, toValue value: String!) {
        Intercom.updateUserWithAttributes(["custom_attributes": [property: value]])
    }
    
    public override func incrementUserProperty(counterName: String!, byInt amount: NSNumber!) {
        // Not Implemented
    }
}
