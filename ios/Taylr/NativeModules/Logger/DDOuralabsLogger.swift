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

extension OULogLevel {
    var description: String {
        switch self {
        case .Trace: return "Trace"
        case .Debug: return "Debug"
        case .Info: return "Info"
        case .Warn: return "Warn"
        case .Error: return "Error"
        case .Fatal: return "Fatal"
        }
    }
}

class DDOuralabsLogger : DDAbstractLogger {
    var context: AnalyticsContext!
    
    init(apiKey: String, livetail: Bool) {
        Ouralabs.initWithKey(apiKey)
        Ouralabs.setLiveTail(livetail)
        Ouralabs.setLogLifecycle(true)
        Ouralabs.setDiskOnly(true)
        Ouralabs.setLogUncaughtExceptions(true) // Should be safe vs. crashlytics
        Ouralabs.setLoggerLogsAllowed(true) // Allow OuralabsLogInner
        Ouralabs.setSettingsChangedBlock { livetail, logLevel in
            DDLogDebug("Settings did change livetail=\(livetail) logLevel=\(logLevel.description)")
        }
        
        super.init()
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        let level: OULogLevel
        switch logMessage.logLevel {
        case .Verbose:
            level = .Trace
        case .Debug:
            level = .Debug
        case .Info:
            level = .Info
        case .Warn:
            level = .Warn
        case .Error:
            level = .Error
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
    
    func setAttribute(key: String, value: AnyObject?) {
        assert([OUAttr1, OUAttr2, OUAttr3].contains(key), "Key must be one of 3 predefined attributes")
        DDLogDebug("Will update attribute \(key)=\(value)")
        var attrs = Ouralabs.getAttributes() ?? [:]
        attrs[key] = value
        Ouralabs.setAttributes(attrs)
    }
    
    func launch(currentBuild: String, previousBuild: String?) {
        setAttribute(OUAttr1, value: context.userId)
        setAttribute(OUAttr2, value: context.fullname)
        setAttribute(OUAttr3, value: context.deviceName)
        DDLogInfo("Ouralabs did launch deviceId=\(context.deviceId) userId=\(context.userId)")
    }
    
    func login(isNewUser: Bool) {
        setAttribute(OUAttr1, value: context.userId)
    }
    
    func logout() {
        setAttribute(OUAttr1, value: nil)
        setAttribute(OUAttr2, value: nil)
    }
    
    func updateFullname() {
        setAttribute(OUAttr2, value: context.fullname)
    }
}