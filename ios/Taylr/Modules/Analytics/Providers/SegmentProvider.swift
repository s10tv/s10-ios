//
//  SegmentProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import AnalyticsSwift

public class SegmentProvider : NSObject, AnalyticsProvider {
    
    let segment: AnalyticsSwift.Analytics
    
    init(writeKey: String) {
        segment = AnalyticsSwift.Analytics.create(writeKey)
    }
    
    func identifyUser(userId: String) {
        segment.enqueue(IdentifyMessageBuilder().userId(userId))
    }
    
    func identifyDevice(deviceId: String) {
        segment.enqueue(IdentifyMessageBuilder().anonymousId(deviceId))
    }
    
    func track(event: String!, properties: [NSObject : AnyObject]?) {
        var msg = TrackMessageBuilder(event: event)
        if let properties = properties {
            var props : [String: AnyObject] = [:]
            for (k, v) in properties {
                if let k = k as? String {
                    props[k] = v
                }
            }
            msg = msg.properties(props)
        }
        segment.enqueue(msg)
    }
    
    func setUserEmail(email: String) {
        setUserProperties(["Email": email])
    }
    
    func setUserFullname(fullname: String) {
        setUserProperties(["Full Name": fullname])
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
        segment.enqueue(IdentifyMessageBuilder().traits(properties))
    }
}
