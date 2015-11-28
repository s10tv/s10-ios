//
//  DDNSLogger.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
#if Debug
import NSLogger
#endif

class DDNSLogger : DDAbstractLogger {
    #if Debug
    let logger = LoggerInit()
    
    override init() {
        var options = kLoggerOption_BufferLogsUntilConnection
        if let hostName = NSProcessInfo().environment["NSLoggerViewerHost"] {
            LoggerSetViewerHost(logger, hostName, 50000)
        }
        if let bonjourName = NSProcessInfo().environment["NSLoggerBonjourName"] {
            LoggerSetupBonjour(logger, nil, bonjourName)
            options = options | kLoggerOption_BrowseBonjour | kLoggerOption_BrowseOnlyLocalDomain
        }
        LoggerSetOptions(logger, UInt32(options))
        LoggerStart(logger)
        super.init()
        logFormatter = TagLogFormatter(timestamp: false, level: false, domain: false)
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        let level: Int32
        switch logMessage.flag {
        case DDLogFlag.Verbose:
            level = 4
        case DDLogFlag.Debug:
            level = 3
        case DDLogFlag.Info:
            level = 2
        case DDLogFlag.Warning:
            level = 1
        case DDLogFlag.Error:
            level = 0
        default:
            return
        }
        let formatter = self.valueForKey("_logFormatter") as? DDLogFormatter // Make this performant
        LogMessageRawToF(logger,
            (logMessage.fileName as NSString).UTF8String,
            Int32(logMessage.line),
            (logMessage.function as NSString).UTF8String,
            logMessage.domain,
            level,
            formatter?.formatLogMessage(logMessage) ?? logMessage.message
        )
    }
    #endif
}
