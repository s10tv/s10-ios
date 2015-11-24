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
    }
    
    func track(event: String!, properties: [NSObject : AnyObject]?) {
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
    }
}
