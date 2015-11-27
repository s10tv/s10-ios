//
//  IntercomProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Intercom
import CocoaLumberjack


// TODO: Add more information to Intercom
// https://doc.intercom.io/api/#user-model
// Built in: Avatar
// Built in: Social profiles
// Mixpanel Url
// Taylr Api url
// UXCam URL
// Ouralabs URL
// Ampiltude URL
// Crashlytics URL?
// Branch URL?
// Segment URL?

@objc(TSIntercomProvider)
public class IntercomProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!
    
    init(appId: String, apiKey: String) {
        Intercom.setApiKey(apiKey, forAppId: appId)
        Intercom.setPreviewPosition(.BottomRight)
    }
    
    func appInstall() {
        Intercom.registerUnidentifiedUser()
        setUserProperties(["Device Name": context.deviceName])
    }
    
    func login(isNewUser: Bool) {
        guard let userId = context.userId else {
            DDLogError("Cannot call Intercom.login without userId")
            return
        }
        if let email = context.email {
            Intercom.registerUserWithUserId(userId, email: email)
        } else {
            Intercom.registerUserWithUserId(userId)
        }
    }
    
    func logout() {
        Intercom.reset()
        Intercom.registerUnidentifiedUser()
        setUserProperties(["Device Name": context.deviceName])
    }
    
    func updateEmail() {
        Intercom.updateUserWithAttributes(["email": context.email ?? NSNull()])
    }
    
    func updateFullname() {
        Intercom.updateUserWithAttributes(["name": context.fullname ?? NSNull()])
    }
    
    func setUserProperties(properties: [NSObject : AnyObject]) {
        Intercom.updateUserWithAttributes(["custom_attributes": properties])
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        if let properties = properties {
            Intercom.logEventWithName(event, metaData: properties)
        } else {
            Intercom.logEventWithName(event)
        }
    }
    
    func registerPushToken(pushToken: NSData) {
        Intercom.setDeviceToken(pushToken)
    }
    
    @objc func presentMessageComposer() {
        dispatch_async(dispatch_get_main_queue()) {
            Intercom.presentMessageComposer()
        }
    }
    
    @objc func presentConversationList() {
        dispatch_async(dispatch_get_main_queue()) {
            Intercom.presentConversationList()
        }
    }
}
