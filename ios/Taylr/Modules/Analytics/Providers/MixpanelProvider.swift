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
    
    init(apiToken: String, launchOptions: [NSObject: AnyObject]?) {
        mixpanel = Mixpanel.sharedInstanceWithToken(apiToken, launchOptions: launchOptions)
    }
    
    func updateIdentity() {
        if let userId = context.userId {
            DDLogInfo("Will identify user userId=\(userId) nameTag=\(context.fullname)")
            mixpanel.identify(userId)
            mixpanel.nameTag = context.fullname
        } else {
            DDLogInfo("User anonymous. Will use distinctId=\(mixpanel.distinctId) nameTag=\(context.deviceName)")
            mixpanel.nameTag = context.deviceName
        }
        let props = [
            "User ID": context.userId ?? NSNull(),
            "Device ID": context.deviceId
        ]
        mixpanel.registerSuperProperties(props)
        setUserProperties(props)
    }
    
    override func launch(currentBuild: String, previousBuild: String?) {
        updateIdentity()
        mixpanel.registerSuperProperties(["Build": currentBuild])
        super.launch(currentBuild, previousBuild: previousBuild)
        DDLogInfo("Did launch")
    }
    
    override func login(isNewUser: Bool) {
        if isNewUser {
            assert(mixpanel.distinctId != context.userId, "Expecting userId != distinctId at signup time")
            DDLogInfo("Will createAlias userId=\(mixpanel.distinctId) deviceId=\(context.deviceId)")
            mixpanel.createAlias(context.userId!, forDistinctID: mixpanel.distinctId)
            mixpanel.flush()
        }
        updateIdentity()
        super.login(isNewUser)
        DDLogInfo("Did login")
    }
    
    override func logout() {
        super.logout()
        flush()
        reset()
        updateIdentity()
        DDLogInfo("Did logout")
    }
    
    override func updatePhone() {
        DDLogDebug("Will update people $phone=\(context.phone)")
        mixpanel.people.set("$phone", to: context.phone ?? "")
    }
    
    override func updateEmail() {
        DDLogDebug("Will update people $email=\(context.email)")
        mixpanel.people.set("$email", to: context.email ?? "")
    }
    
    override func updateFullname() {
        DDLogDebug("Will update people & set nameTag $name=\(context.fullname) nameTag=\(context.fullname)")
        mixpanel.nameTag = context.fullname
        mixpanel.people.set("$name", to: context.fullname ?? "")
    }
    
    override func setUserProperties(properties: [NSObject : AnyObject]) {
        DDLogVerbose("Will update people properties", tag: properties)
        mixpanel.people.set(properties)
    }
    
    override func track(event: String, properties: [NSObject : AnyObject]? = nil) {
        DDLogVerbose("Will track event=\(event)", tag: properties)
        mixpanel.track(event, properties: properties)
    }
    
    func registerPushToken(pushToken: NSData) {
        mixpanel.people.addPushDeviceToken(pushToken)
    }
    
    func trackPushNotification(userInfo: [NSObject : AnyObject]) {
        mixpanel.trackPushNotification(userInfo)
    }
    
    func flush() {
        DDLogDebug("Will flush")
        mixpanel.flush()
    }
    
    func reset() {
        DDLogDebug("Will reset")
        mixpanel.reset()
    }
}

// MARK: - Method Swizzling

extension Mixpanel {
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== Mixpanel.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = Selector("defaultDistinctId")
            let swizzledSelector = Selector("ts_defaultDistinctId")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
            DDLogInfo("Did swizzle defaultDistinctId with ts_defaultDistinctId")
        }
    }
    
    func ts_defaultDistinctId() -> String {
        let deviceId = Environment().deviceId
        DDLogDebug("Will return swizzled defaultDistinctId deviceId=\(deviceId)")
        return deviceId
    }
}