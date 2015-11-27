//
//  UXCamProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Intercom
//#if Release
import UXCam
//#endif

public class UXCamProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!

    init(apiKey: String) {
        UXCam.startWithKey(apiKey)
    }
    
    func login(isNewUser: Bool) {
        UXCam.tagUsersName(context.userId)
        UXCam.markSessionAsFavorite()
    }
    
    func logout() {
        UXCam.markSessionAsFavorite()
        UXCam.tagUsersName(nil)
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        UXCam.addTag(event)
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]?) {
        UXCam.tagScreenName(name)
    }
}
