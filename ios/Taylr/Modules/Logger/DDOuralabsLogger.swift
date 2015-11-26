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
        switch logMessage.level {
        case .Verbose:
            level = .Trace
        case .Debug:
            level = .Debug
        case .Info:
            level = .Info
        case .Warning:
            level = .Warn
        case .Error:
            level = .Error
        default:
            return
        }
        let tag = (logMessage.tag as? String) ?? logMessage.fileName
        Ouralabs.log(level, tag: tag, message: logMessage.message, error: nil)
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