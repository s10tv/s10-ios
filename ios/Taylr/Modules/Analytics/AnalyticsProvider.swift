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
    // TODO: Make this a superclass in addition to protocol
//    func updateUsername() {
//        setUserProperties?(["Username": context.username ?? NSNull()])
//    }
//    func updatePhone() {
//        setUserProperties?(["Phone": context.phone ?? NSNull()])
//    }
//    func updateEmail() {
//        setUserProperties?(["Email": context.email ?? NSNull()])
//    }
//    func updateFullname() {
//        setUserProperties?(["Fullname": context.fullname ?? NSNull()])
//    }
    
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

