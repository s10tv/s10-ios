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
    
    func appLaunch() {
        if let userId = context.userId {
            crashlytics.setUserIdentifier(userId)
        }
        crashlytics.setObjectValue(context.deviceId, forKey: "Device Id")
        crashlytics.setObjectValue(context.deviceName, forKey: "Device Name")
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
        crashlytics.setUserIdentifier(nil)
    }

    func updateEmail() {
        crashlytics.setUserEmail(context.email)
    }
    
    func updateFullname() {
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