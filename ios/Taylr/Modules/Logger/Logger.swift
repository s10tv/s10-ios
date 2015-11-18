//
//  Logging.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import CocoaLumberjack

@objc(TSLogger)
public class Logger : NSObject {
    
    init(config: AppConfig) {
        super.init()
        DDLog.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        DDLog.addLogger(DDOuralabsLogger(apiKey: config.ouralabsKey))
        
        DDLogInfo("Logger initialized")
    }

    @objc
    func log(logText: String, level: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        let lvl: DDLogLevel
        let flg: DDLogFlag
        switch level {
        case "verbose":
            lvl = .Verbose
            flg = .Verbose
        case "debug":
            lvl = .Debug
            flg = .Debug
        case "info":
            lvl = .Info
            flg = .Info
        case "warn":
            lvl = .Warning
            flg = .Warning
        case "error":
            lvl = .Error
            flg = .Error
        default:
            // Unrecognized logging level defaults to warning
            lvl = .Warning
            flg = .Warning
        }
        
        if lvl.rawValue & flg.rawValue != 0 {
            let logMessage = DDLogMessage(message: logText, level: lvl, flag: flg, context: 0, file: file, function: function, line: UInt(line), tag: nil, options: [.CopyFile, .CopyFunction], timestamp: nil)
            DDLog.log(true, message: logMessage)
        }
    }
}