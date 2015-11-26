//
//  DDOuralabsLogger.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Ouralabs

class DDOuralabsLogger : DDAbstractLogger {
    init(apiKey: String) {
        Ouralabs.initWithKey(apiKey)
        super.init()
    }
    
    func setAttribute(key: String, value: AnyObject?) {
        assert([OUAttr1, OUAttr2, OUAttr3].contains(key), "Key must be one of 3 predefined attributes")
        var attrs = Ouralabs.getAttributes() ?? [:]
        attrs[key] = value
        Ouralabs.setAttributes(attrs)
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        let level: OULogLevel
        switch logMessage.flag {
        case DDLogFlag.Verbose:
            level = .Trace
        case DDLogFlag.Debug:
            level = .Debug
        case DDLogFlag.Info:
            level = .Info
        case DDLogFlag.Warning:
            level = .Warn
        case DDLogFlag.Error:
            level = .Error
        default:
            return
        }
        // We're constructing KVP 3 times, any perf issue?
        let tag = logMessage.domain
        if let error = logMessage.error {
            Ouralabs.log(level, tag: tag, message: logMessage.message, error: error)
        } else {
            Ouralabs.log(level, tag: tag, message: logMessage.message, kvp: logMessage.kvp)
        }
    }
}

extension DDOuralabsLogger : AnalyticsProvider {
    func identifyDevice(deviceId: String) {
        setAttribute(OUAttr1, value: deviceId)
    }
    
    func identifyUser(userId: String) {
        setAttribute(OUAttr2, value: userId)
    }
    
    func setUserFullname(fullname: String) {
        setAttribute(OUAttr3, value: fullname)
    }
}