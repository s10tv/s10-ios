//
//  UXCamProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
//#if Release
import UXCam
//#endif

public class UXCamProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!

    init(apiKey: String) {
        UXCam.startWithKey(apiKey)
    }
    
    func launch(currentBuild: String, previousBuild: String?) {
        if let userId = context.userId {
            UXCam.tagUsersName(userId)
        }
        if previousBuild == nil || currentBuild != previousBuild {
            UXCam.markSessionAsFavorite()
            UXCam.addTag("App: Upgrade")
            DDLogInfo("Will tag App: Upgrade")
        }
        DDLogInfo("UXCam launch, usersName=\(context.userId)")
    }
    
    func login(isNewUser: Bool) {
        DDLogInfo("Will mark session as favorite and tag Login usersName=\(context.userId)")
        UXCam.tagUsersName(context.userId)
        UXCam.markSessionAsFavorite()
        UXCam.addTag("Login")
    }
    
    func logout() {
        DDLogInfo("Will mark session as favorite and tag Logout usersName=\(context.deviceName)")
        UXCam.markSessionAsFavorite()
        UXCam.addTag("Logout")
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        DDLogDebug("Will tag tag=\(event)")
        UXCam.addTag(event)
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]?) {
        DDLogDebug("Will tag screenName=\(name)")
        UXCam.tagScreenName(name)
    }
}
