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
    
    func setUserPhone(phone: String) {
        mixpanel.people.set(["$phone": phone])
    }
    
    func setUserEmail(email: String) {
        mixpanel.people.set(["$email": email])
    }
    
    func setUserFullname(fullname: String) {
        mixpanel.nameTag = fullname
        mixpanel.people.set(["$name": fullname])
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
        mixpanel.people.set(properties)
    }
}
