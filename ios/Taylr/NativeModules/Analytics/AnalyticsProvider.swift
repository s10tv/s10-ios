//
//  AnalyticsProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/23/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

enum LifecycleEvent : String {
    case Install = "App: Install"
    case Upgrade = "App: Upgrade"
    case AppOpen = "App: Open"
    case AppClose = "App: Close"
    case Login = "Login"
    case Logout = "Logout"
}

@objc protocol AnalyticsContext : class {
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
    
    func launch(currentBuild: String, previousBuild: String?)
    func login(isNewUser: Bool)
    func logout()
    
    optional func appOpen()
    optional func appClose()
    
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
    
    optional func flush()
}

extension AnalyticsProvider {
    
    func track(event: LifecycleEvent, properties: [NSObject : AnyObject]? = nil) {
        track?(event.rawValue, properties: properties)
    }

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
}

extension BaseAnalyticsProvider : AnalyticsProvider {
    
    func launch(currentBuild: String, previousBuild: String?) {
        if previousBuild == nil {
            track(.Install)
        } else if let previousBuild = previousBuild where previousBuild != currentBuild {
            // Env should be dependency injected
            track(.Upgrade, properties: [
                "From Build": previousBuild,
                "To Build": currentBuild
            ])
        }
    }
    
    func login(isNewUser: Bool) {
        track(.Login, properties: ["New User": isNewUser])
    }
    
    func logout() {
        track(.Logout)
    }
    
    func appOpen() {
        track(.AppOpen)
    }
    
    func appClose() {
        track(.AppClose)
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
