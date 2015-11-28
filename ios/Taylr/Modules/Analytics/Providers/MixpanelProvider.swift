//
//  MixpanelProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Mixpanel
import CocoaLumberjack

public class MixpanelProvider : BaseAnalyticsProvider {
    
    let mixpanel: Mixpanel
    var people: MixpanelPeople? {
        return context.userId != nil ? mixpanel.people : nil
    }
    
    init(apiToken: String, launchOptions: [NSObject: AnyObject]?) {
        mixpanel = Mixpanel.sharedInstanceWithToken(apiToken, launchOptions: launchOptions)
    }
    
    func identifyAnonymousDevice() {
        mixpanel.identify(context.deviceId)
        mixpanel.nameTag = context.deviceName
        mixpanel.registerSuperProperties(["Device ID": context.deviceId])
    }
    
    override func appLaunch() {
        if context.isNewInstall {
            identifyAnonymousDevice()
            track("App: Install")
        }
    }
    
    override func login(isNewUser: Bool) {
        if isNewUser {
            mixpanel.createAlias(context.userId, forDistinctID: context.deviceId)
            DDLogInfo("Mixpanel createAlias userI=\(context.userId!) deviceId=\(context.deviceId)")
        }
        mixpanel.registerSuperProperties(["User ID": context.userId!])
        mixpanel.identify(context.userId)
        people?.set("User ID", to: context.userId)
        track("Login", properties: ["New User": isNewUser])
    }
    
    override func logout() {
        track("Logout")
        flush()
        mixpanel.reset()
        identifyAnonymousDevice()
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
