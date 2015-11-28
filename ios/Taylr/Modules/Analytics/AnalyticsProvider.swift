//
//  AnalyticsProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/23/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

@objc protocol AnalyticsContext : class {
    var isNewInstall: Bool { get }
    var deviceId: String { get }
    var deviceName: String { get }
    var userId: String? { get }
    var username: String? { get }
    var phone: String? { get }
    var email: String? { get }
    var fullname: String? { get }
}

@objc protocol AnalyticsProvider : class {
    var context: AnalyticsContext! { get set }
    
    optional func appLaunch()
    optional func appOpen()
    optional func appClose()
    
    func login(isNewUser: Bool)
    func logout()
    
    // Only gets called after user is authenticated
    optional func updateUsername()
    optional func updatePhone()
    optional func updateEmail()
    optional func updateFullname()
    
    optional func setUserProperties(properties: [NSObject : AnyObject])
    optional func track(event: String, properties: [NSObject : AnyObject]?)
    optional func screen(name: String, properties: [NSObject : AnyObject]?)
    
    optional func registerPushToken(pushToken: NSData)
    optional func trackPushNotification(userInfo: [NSObject : AnyObject])
    
    // Utils
    optional func flush()
}

extension AnalyticsProvider {
    
    // Helper
    func convertProperties(properties: [NSObject : AnyObject]?) -> [String: AnyObject] {
        if let properties = properties {
            var props : [String: AnyObject] = [:]
            for (k, v) in properties {
                if let k = k as? String {
                    props[k] = v
                }
            }
            return props
        }
        return [:]
    }
}

// MARK: - BaseAnalyticsProvider

public class BaseAnalyticsProvider : NSObject {
    var context: AnalyticsContext!
    
    func updateIdentity() {
        // To be overwridden by subclass, called at appLaunch, login and logout
    }
}

extension BaseAnalyticsProvider : AnalyticsProvider {
    
    func appLaunch() {
        updateIdentity()
        if context.isNewInstall {
            track("App: Install")
        }
    }
    
    func appOpen() {
        track("App: Open")
    }
    
    func appClose() {
        track("App: Close")
    }
    
    func login(isNewUser: Bool) {
        assert(context.userId != nil, "userId should not be nil after login")
        updateIdentity()
        track("Login", properties: ["New User": isNewUser])
    }
    
    func logout() {
        assert(context.userId == nil, "userId should be nil after logout")
        track("Logout")
        updateIdentity()
    }
    
    func updateUsername() {
        setUserProperties(["Username": context.username ?? NSNull()])
    }
    func updatePhone() {
        setUserProperties(["Phone": context.phone ?? NSNull()])
    }
    func updateEmail() {
        setUserProperties(["Email": context.email ?? NSNull()])
    }
    func updateFullname() {
        setUserProperties(["Full Name": context.fullname ?? NSNull()])
    }
    
    func setUserProperties(properties: [NSObject : AnyObject]) {
        // To be implemented by subclass
    }
    
    func track(event: String, properties: [NSObject : AnyObject]? = nil) {
        // To be implemented by subclass
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]? = nil) {
        track("Screen: \(name)", properties: properties)
    }
}
