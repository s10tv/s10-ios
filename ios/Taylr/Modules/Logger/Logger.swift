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
    
    func addLogger(logger: DDLogger) {
        DDLog.addLogger(logger)
    }

    @objc func log(logText: String, level: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
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

extension DDLogMessage {
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