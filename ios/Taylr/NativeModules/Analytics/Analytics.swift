//
//  Analytics.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack

public func TSATrack(event: String, properties: [String: AnyObject]? = nil) {
    assert(Analytics.defaultInstance != nil)
    Analytics.defaultInstance?.track(event, properties: properties)
}

public func TSAScreen(name: String, properties: [String: AnyObject]? = nil) {
    assert(Analytics.defaultInstance != nil)
    Analytics.defaultInstance?.screen(name, properties: properties)
}

public func TSASetUserProperties(properties: [String: AnyObject]) {
    assert(Analytics.defaultInstance != nil)
    Analytics.defaultInstance?.setUserProperties(properties)
}

extension Session : AnalyticsContext {
    var deviceId: String { return env.deviceId }
    var deviceName: String { return env.deviceName }
}

@objc(TSAnalytics)
public class Analytics : NSObject {
    public static var defaultInstance: Analytics?
    
    let session: Session
    private var providers: [AnalyticsProvider] = []
    
    init(session: Session) {
        self.session = session
    }
    
    func addProviders(providers: [AnalyticsProvider]) {
        for provider in providers {
            provider.context = session
            self.providers.append(provider)
        }
    }
    
    func appDidLaunch(launchOptions: [NSObject: AnyObject]?) {
        eachProvider { $0.launch(self.session.env.build, previousBuild: self.session.previousBuild) }
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

    // MARK: Helper
    
    private func eachProvider(authOnly authOnly: Bool = false, block: (AnalyticsProvider) -> ()) {
        if authOnly == false || session.loggedIn == true {
            for provider in providers {
                block(provider)
            }
        }
    }
}

// MARK: - JavaScript API

extension Analytics {
    
    @objc func userDidLogin(isNewUser: Bool) {
        eachProvider { $0.login(isNewUser) }
        DDLogInfo("userDidLogin isNewUser=\(isNewUser)")
    }
    
    @objc func userDidLogout() {
        eachProvider { $0.logout() }
        DDLogInfo("userDidLogout")
    }
    
    @objc func updateUsername() {
        eachProvider { $0.updateUsername?() }
        DDLogInfo("update username=\(session.username)")
    }
    
    @objc func updatePhone() {
        eachProvider { $0.updatePhone?() }
        DDLogInfo("update phone=\(session.phone)")
    }
    
    @objc func updateEmail() {
        eachProvider { $0.updateEmail?() }
        DDLogInfo("update email=\(session.email)")
    }
    
    @objc func updateFullname() {
        eachProvider { $0.updateFullname?() }
        DDLogInfo("update fullname=\(session.fullname)")
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
        DDLogInfo("Flush analytics providers")
    }
}
