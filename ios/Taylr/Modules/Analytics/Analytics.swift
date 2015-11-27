//
//  Analytics.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SwiftyUserDefaults

public let Analytics = TSAnalytics()

@objc(TSAnalytics)
public class TSAnalytics : NSObject {
    private var providers: [AnalyticsProvider] = []
    
    let isNewInstall: Bool
    let deviceId: String
    let deviceName: String
    
    override init() {
        isNewInstall = (Defaults[.appDidInstall] == false)
        Defaults[.appDidInstall] = true
        let env = Environment() // How do we dependency inject this? If at all
        deviceId = env.deviceId
        deviceName = env.deviceName
    }
    
    func addProviders(providers: [AnalyticsProvider]) {
        for provider in providers {
            provider.context = self
            self.providers.append(provider)
        }
    }
    
    // MARK: Helper
    
    private func eachProvider(authOnly authOnly: Bool = false, block: (AnalyticsProvider) -> ()) {
        if authOnly == false || userId != nil {
            for provider in providers {
                block(provider)
            }
        }
    }
}

// MARK: - AnalyticsContext

extension DefaultsKeys {
    private static let appDidInstall = DefaultsKey<Bool>("ts_appDidInstall")
    private static let userId = DefaultsKey<String?>("ts_userId")
    private static let username = DefaultsKey<String?>("ts_username")
    private static let email = DefaultsKey<String?>("ts_email")
    private static let phone = DefaultsKey<String?>("ts_phone")
    private static let fullname = DefaultsKey<String?>("ts_fullname")
}

extension TSAnalytics : AnalyticsContext {
    var userId: String? {
        get { return Defaults[.userId] }
        set { Defaults[.userId] = newValue }
    }
    var username: String? {
        get { return Defaults[.username] }
        set { Defaults[.username] = newValue }
    }
    var email: String? {
        get { return Defaults[.email] }
        set { Defaults[.email] = newValue }
    }
    var phone: String? {
        get { return Defaults[.phone] }
        set { Defaults[.phone] = newValue }
    }
    var fullname: String? {
        get { return Defaults[.fullname] }
        set { Defaults[.fullname] = newValue }
    }
}

// MARK: - AppDelegate API

extension TSAnalytics {
    
    func appDidLaunch(launchOptions: [NSObject: AnyObject]?) {
        eachProvider { $0.appLaunch?() }
        eachProvider { $0.appOpen?() }
    }
    
    func appWillEnterForeground() {
        eachProvider { $0.appOpen?() }
    }
    
    func appDidEnterBackground() {
        eachProvider { $0.appClose?() }
    }
    
    func appDidRegisterForPushToken(token: NSData) {
        eachProvider { $0.registerPushToken?(token) }
    }
    
    func appDidReceivePushNotification(userInfo: [NSObject: AnyObject]) {
        eachProvider { $0.trackPushNotification?(userInfo) }
    }
}

// MARK: - JavaScript API

extension TSAnalytics {
    
    @objc func userDidLogin(userId: String, isNewUser: Bool) {
        self.userId = userId
        eachProvider { $0.login(isNewUser) }
    }
    
    @objc func userDidLogout() {
        self.userId = nil
        self.username = nil
        self.phone = nil
        self.email = nil
        self.fullname = nil
        eachProvider { $0.logout() }
    }
    
    @objc func setUserUsername(username: String?) {
        self.username = username
        eachProvider { $0.updateUsername?() }
        DDLogInfo("setUserUsername username=\(username)")
    }
    
    @objc func setUserPhone(phone: String?) {
        self.phone = phone
        eachProvider { $0.updatePhone?() }
        DDLogInfo("setUserPhone phone=\(phone)")
    }
    
    @objc func setUserEmail(email: String?) {
        self.email = email
        eachProvider { $0.updateEmail?() }
        DDLogInfo("setUserEmail email=\(email)")
    }
    
    @objc func setUserFullname(fullname: String) {
        self.fullname = fullname
        eachProvider { $0.updateFullname?() }
        DDLogInfo("setUserFullName fullname=\(fullname)")
    }
    
    @objc func track(event: String, properties: [String: AnyObject]? = nil) {
        eachProvider { $0.track?(event, properties: properties) }
        DDLogDebug("Track event=\(event)", tag: properties)
    }
    
    @objc func screen(name: String, properties: [String: AnyObject]? = nil) {
        eachProvider { $0.screen?(name, properties: properties) }
        DDLogDebug("Screen name=\(name)", tag: properties)
    }
    
    @objc func setUserProperties(properties: [String: AnyObject]) {
        eachProvider { $0.setUserProperties?(properties) }
        DDLogDebug("Set user properties=\(properties)")
    }
    
    @objc func flush() {
        eachProvider { $0.flush?() }
        DDLogDebug("Flush analytics providers")
    }
}
