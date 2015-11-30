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

func getUTF8String(string: String?) -> UnsafePointer<Int8> {
    if let string = string {
        return (string as NSString).UTF8String
    }
    return UnsafePointer()
}

class DDNSLogger : DDAbstractLogger {
    #if Debug
    let logger = LoggerInit()
    
    init(viewerHostName: String?) {
        let hostName = NSProcessInfo().environment["NSLoggerViewerHost"] ?? viewerHostName ?? "localhost"
        let bonjourName = NSProcessInfo().environment["NSLoggerBonjourName"] ?? "taylr-nslogger"
        LoggerSetViewerHost(logger, hostName, 50000)
        LoggerSetupBonjour(logger, nil, bonjourName)
        LoggerSetOptions(logger, UInt32(
            kLoggerOption_BufferLogsUntilConnection |
            kLoggerOption_UseSSL |
            kLoggerOption_BrowseBonjour |
            kLoggerOption_BrowseOnlyLocalDomain
        ))
        LoggerStart(logger)
        print("Did start NSLogger with viewerHost=\(hostName) bonjourName=\(bonjourName)")
        super.init()
        logFormatter = TagLogFormatter(timestamp: false, level: false, domain: false)
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        let level: Int32
        switch logMessage.logLevel {
        case .Verbose:
            level = 4
        case .Debug:
            level = 3
        case .Info:
            level = 2
        case .Warn:
            level = 1
        case .Error:
            level = 0
        }
        (logMessage.fileName as NSString)
        LogMessageRawToF(logger,
            getUTF8String(logMessage.fileName),
            Int32(logMessage.line),
            getUTF8String(logMessage.function),
            logMessage.domain,
            level,
            formatMessage(logMessage)
        )
    }
    #endif
}
