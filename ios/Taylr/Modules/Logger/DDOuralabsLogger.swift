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
        Ouralabs.setAttributes(["deviceId": deviceId])
    }
    
    func identifyUser(userId: String) {
        Ouralabs.setAttributes(["userId": userId])
    }
    
    func setUserProperties(properties: [String : AnyObject]) {
        Ouralabs.setAttributes(properties)
    }
}