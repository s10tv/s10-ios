//
//  Logging.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

let Log = Logger()

enum LogLevel : Int {
    case Error = 0
    case Warn
    case Info
    case Debug
    case Verbose
}

class Logger  {
    let nslogger : NSLogger = NSLogger()
    
    func verbose(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Verbose, function: function, file: file, line: line)
    }
    
    func debug(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Debug, function: function, file: file, line: line)
    }
    
    func info(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Info, function: function, file: file, line: line)
    }
    
    func warn(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Warn, function: function, file: file, line: line)
    }
    
    func error(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Error, function: function, file: file, line: line)
    }
    
    func log(message: String,
             level: LogLevel,
             function: String = __FUNCTION__,
             file: String = __FILE__,
             line: Int = __LINE__) {
        nslogger.logWithFilename(file, lineNumber: Int32(line), functionName: function, domain: nil, level: Int32(level.rawValue), message: message)
    }
}