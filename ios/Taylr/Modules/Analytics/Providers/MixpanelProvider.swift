//
//  MixpanelProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Mixpanel

public class MixpanelProvider : BaseAnalyticsProvider {
    
    let mixpanel: Mixpanel
    var people: MixpanelPeople? {
        return mixpanel.people // People Records for all for now
//        return context.userId != nil ? mixpanel.people : nil
    }
    
    init(apiToken: String, launchOptions: [NSObject: AnyObject]?) {
        mixpanel = Mixpanel.sharedInstanceWithToken(apiToken, launchOptions: launchOptions)
    }
    
    override func updateIdentity() {
        if let userId = context.userId {
            mixpanel.identify(userId)
        } else {
            mixpanel.identify(context.deviceId)
        }
        if let fullname = context.fullname {
            mixpanel.nameTag = fullname
        } else {
            mixpanel.nameTag = context.deviceName
        }
        if context.isNewInstall {
            track("App: Install", properties: nil)
        }
        people?.set("Device Name", to: context.deviceName)
    }
    
    override func login(isNewUser: Bool) {
        mixpanel.identify(context.userId)
        if isNewUser {
            mixpanel.createAlias(context.userId, forDistinctID: context.deviceId)
        }
        track("Login", properties: ["New User": isNewUser])
    }
    
    override func logout() {
        track("Logout")
        mixpanel.identify(context.deviceId)
    }
    
    override func updatePhone() {
        people?.set("$phone", to: context.phone ?? "")
    }
    
    override func updateEmail() {
        people?.set("$email", to: context.email ?? "")
    }
    
    override func updateFullname() {
        mixpanel.nameTag = context.fullname
        people?.set("$name", to: context.fullname ?? "")
    }
    
    override func setUserProperties(properties: [NSObject : AnyObject]) {
        people?.set(properties)
    }
    
    override func track(event: String, properties: [NSObject : AnyObject]? = nil) {
        mixpanel.track(event, properties: properties)
    }
    
    func registerPushToken(pushToken: NSData) {
        people?.addPushDeviceToken(pushToken)
    }
    
    func trackPushNotification(userInfo: [NSObject : AnyObject]) {
        mixpanel.trackPushNotification(userInfo)
    }
    
    func flush() {
        mixpanel.flush()
    }
}
