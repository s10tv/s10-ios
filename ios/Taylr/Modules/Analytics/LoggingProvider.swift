//
//  LoggingProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import ARAnalytics

public class LoggingProvider : ARAnalyticalProvider {
    public override func identifyUserWithID(userID: String!, andEmailAddress email: String!) {
        DDLogInfo("Identify userId=\(userID)")
    }
    
    public override func event(event: String!, withProperties properties: [NSObject : AnyObject]!) {
        DDLogDebug("Track event=\(event) properties=\(properties)")
    }
    
    public override func setUserProperty(property: String!, toValue value: String!) {
        DDLogDebug("Set user property name=\(property) value=\(value)")
    }
    
    public override func incrementUserProperty(counterName: String!, byInt amount: NSNumber!) {
        DDLogDebug("Increment user property name=\(counterName) amount=\(amount)")
    }
}
