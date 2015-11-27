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
import UXCam

// TODO: Add more information to Intercom
// https://doc.intercom.io/api/#user-model
// Ampiltude URL
// Ouralabs URL (damn it...)
// Crashlytics URL?
// Branch URL?
// Segment URL?

@objc(TSIntercomProvider)
public class IntercomProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!

    let config: AppConfig
    
    init(config: AppConfig) {
        self.config = config
        Intercom.setApiKey(config.intercom.apiKey, forAppId: config.intercom.appId)
        Intercom.setPreviewPosition(.BottomRight)
    }
    
    private func registerUser() {
        if let userId = context.userId {
            if let email = context.email {
                Intercom.registerUserWithUserId(userId, email: email)
            } else {
                Intercom.registerUserWithUserId(userId)
            }
            setUserProperties(["Taylr URL": "https://\(config.serverHostName)/admin/users/\(userId)"])
        } else {
            Intercom.registerUnidentifiedUser()
        }
        let amplitudeId = context.userId ?? context.deviceId
        setUserProperties([
            "Device ID": context.deviceId,
            "Device Name": context.deviceName,
            "Mixpanel URL": "https://mixpanel.com/report/\(config.mixpanel.projectId)/explore/#user?distinct_id=\(context.deviceId)",
            "Amplitude URL": "https://amplitude.com/app/\(config.amplitude.appId)/activity/search?userId=\(amplitudeId)"
        ])
    }
    
    func appLaunch() {
        registerUser()
    }
    
    func appClose() {
        if let url = UXCam.urlForCurrentUser() {
            setUserProperties(["UXCam URL": "http://\(url)"])
        }
    }
    
    func login(isNewUser: Bool) {
        assert(context.userId != nil)
        registerUser()
        track("Login", properties: ["New User": isNewUser])
    }
    
    func logout() {
        track("Logout", properties: nil)
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
}

// MARK: - JS API

extension Intercom {
    
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
