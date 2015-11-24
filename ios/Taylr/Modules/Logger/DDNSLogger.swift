//
//  DDNSLogger.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
//#if DEV
import NSLogger
//#endif

class DDNSLogger : DDAbstractLogger {
    let logger = LoggerInit()
    
    override init() {
        LoggerSetOptions(logger, UInt32(
            kLoggerOption_BufferLogsUntilConnection |
            kLoggerOption_BrowseBonjour |
            kLoggerOption_BrowseOnlyLocalDomain
        ))
        LoggerStart(logger)
        super.init()
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        let level: Int32
        switch logMessage.level {
        case .Verbose:
            level = 4
        case .Debug:
            level = 3
        case .Info:
            level = 2
        case .Warning:
            level = 1
        case .Error:
            level = 0
        default:
            return
        }
        let domain = (logMessage.tag as? String) ?? logMessage.fileName
        LogMessageRawToF(logger,
            (logMessage.fileName as NSString).UTF8String,
            Int32(logMessage.line),
            (logMessage.function as NSString).UTF8String,
            domain,
            level,
            logMessage.message
        )
    }
}
