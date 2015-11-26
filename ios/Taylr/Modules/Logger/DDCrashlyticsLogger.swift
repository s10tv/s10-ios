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
    let crashlytics: Crashlytics
    
    init(crashlytics: Crashlytics) {
        self.crashlytics = crashlytics
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        let level: String
        switch logMessage.flag {
        case DDLogFlag.Verbose:
            level = "VERBOSE"
        case DDLogFlag.Debug:
            level = "DEBUG"
        case DDLogFlag.Info:
            level = "INFO"
        case DDLogFlag.Warning:
            level = "WARN"
        case DDLogFlag.Error:
            level = "ERROR"
        default:
            return
        }
        CLSLogv("\(level) \(logMessage.message)", CVaListPointer(_fromUnsafeMutablePointer: nil))
    }
}

extension DDCrashlyticsLogger : AnalyticsProvider {
    
    func identifyUser(userId: String) {
        crashlytics.setUserIdentifier(userId)
    }
    
    func setUserEmail(email: String) {
        crashlytics.setUserEmail(email)
    }
    
    func setUserFullname(fullname: String) {
        crashlytics.setUserName(fullname)
    }
}