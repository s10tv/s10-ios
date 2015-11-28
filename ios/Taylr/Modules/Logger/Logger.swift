//
//  Logging.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import CocoaLumberjack

let Logger = TSLogger()

@objc(TSLogger)
public class TSLogger : NSObject {
    
    override init() {
        defaultDebugLevel = .Verbose
    }
    
    func addLogger(logger: DDLogger) {
        DDLog.addLogger(logger)
    }

    @objc func log(logText: String, level: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        let lvl = defaultDebugLevel
        let flg: DDLogFlag
        switch level {
        case "verbose":
            flg = .Verbose
        case "debug":
            flg = .Debug
        case "info":
            flg = .Info
        case "warn":
            flg = .Warning
        case "error":
            flg = .Error
        default:
            // Unrecognized logging level defaults to warning
            flg = .Warning
        }
        
        if lvl.rawValue & flg.rawValue != 0 {
            let logMessage = DDLogMessage(message: logText, level: lvl, flag: flg, context: 0, file: file, function: function, line: UInt(line), tag: nil, options: [.CopyFile, .CopyFunction], timestamp: nil)
            DDLog.log(true, message: logMessage)
        }
    }
}

class TagLogFormatter : NSObject, DDLogFormatter {
    func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        let message = NSMutableString()
        if let ts = logMessage.timestamp, let tsStr = formatLogMessageTimestamp(ts) {
            message.appendString("\(tsStr) ")
        }
        
        message.appendString("[\(logMessage.logLevel.rawValue)] ")
        
        if let domain = logMessage.domain where domain.length > 0 {
            message.appendString("{\(domain)} ")
        }
        
        message.appendString(logMessage.message)
        
        var periodAppended = false
        
        if let kvp = logMessage.kvp where kvp.count > 0 {
            message.appendString(". ")
            periodAppended = true
            for (key, value) in kvp {
                message.appendString(" \(key)=\"\(value)\"")
            }
        }
        
        if let error = logMessage.error {
            if !periodAppended {
                message.appendString(". ")
            }
            message.appendString(" error=\(error)")
        }
        
        return message as String
    }
}

extension DDLogMessage {
    enum LogLevel: String {
        case Verbose = "verbose"
        case Debug = "debug"
        case Info = "info"
        case Warn = "warn"
        case Error = "error"
    }
    var logLevel: LogLevel {
        switch flag {
        case DDLogFlag.Verbose:
            return .Verbose
        case DDLogFlag.Debug:
            return .Debug
        case DDLogFlag.Info:
            return .Info
        case DDLogFlag.Warning:
            return .Warn
        case DDLogFlag.Error:
            return .Error
        default:
            // Unexpected level, default to warning
            return .Warn
        }
    }
    var domain: String? {
        return (tag as? String) ?? (kvp?["tag"] as? String) ?? fileName
    }
    
    var kvp: [NSObject: AnyObject]? {
        if let dict = tag as? [NSObject: AnyObject] {
            return dict
        }
        if let optionalDict = tag as? [NSObject: AnyObject?] {
            var dict: [NSObject: AnyObject] = [:]
            for (k, v) in optionalDict {
                dict[k] = v
            }
            return dict
        }
        return nil
    }
    
    var error: NSError? {
        return (tag as? NSError) ?? (kvp?["error"] as? NSError)
    }
}