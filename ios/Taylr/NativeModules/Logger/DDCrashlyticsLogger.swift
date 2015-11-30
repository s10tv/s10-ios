//
//  DDCrashlyticsLogger.swift
//  Taylr
//
//  Created by Tony Xiao on 11/25/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Crashlytics

class DDCrashlyticsLogger : DDAbstractLogger {
    var context: AnalyticsContext!
    let crashlytics: Crashlytics
    
    init(crashlytics: Crashlytics) {
        self.crashlytics = crashlytics
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        withVaList([formatMessage(logMessage)]) { pointer in
            CLSLogv("%@", pointer)
        }
    }
}

extension DDCrashlyticsLogger : AnalyticsProvider {
    
    func launch(currentBuild: String, previousBuild: String?) {
        if let userId = context.userId {
            DDLogInfo("Will set user identifyer userId=\(userId)")
            crashlytics.setUserIdentifier(userId)
        }
        DDLogDebug("Will set deviceId=\(context.deviceId) deviceName=\(context.deviceName)")
        crashlytics.setObjectValue(context.deviceId, forKey: "Device Id")
        crashlytics.setObjectValue(context.deviceName, forKey: "Device Name")
        crashlytics.setUserIdentifier(context.userId)
        crashlytics.setUserEmail(context.email)
        crashlytics.setUserName(context.fullname)
    }
    
    func login(isNewUser: Bool) {
        crashlytics.setUserIdentifier(context.userId!)
        if isNewUser {
            Answers.logSignUpWithMethod(nil, success: true, customAttributes: ["New User": true])
        } else {
            Answers.logLoginWithMethod(nil, success: true, customAttributes: ["New User": false])
        }
    }
    
    func logout() {
        DDLogInfo("Will clear user identifier")
        crashlytics.setUserIdentifier(nil)
        crashlytics.setUserEmail(nil)
        crashlytics.setUserName(nil)
    }

    func updateEmail() {
        DDLogDebug("Will setUserEmail email=\(context.email)")
        crashlytics.setUserEmail(context.email)
    }
    
    func updateFullname() {
        DDLogDebug("Will setUserName fullname=\(context.fullname)")
        crashlytics.setUserName(context.fullname)
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        Answers.logCustomEventWithName(event, customAttributes: convertProperties(properties))
    }
    
    func screen(name: String, properties: [NSObject : AnyObject]?) {
        Answers.logCustomEventWithName("Screen: \(name)", customAttributes: convertProperties(properties))
    }
    
    func setUserProperties(properties: [NSObject : AnyObject]) {
        for (key, value) in properties {
            DDLogDebug("Will set key=\(key) value=\(value)")
            if let key = key as? String {
                switch value {
                case let value as Int:
                    crashlytics.setIntValue(Int32(value), forKey: key)
                case let value as Float:
                    crashlytics.setFloatValue(value, forKey: key)
                case let value as Bool:
                    crashlytics.setBoolValue(value, forKey: key)
                default:
                    crashlytics.setObjectValue(value, forKey: key)
                }
            }
        }
    }
}