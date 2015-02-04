//
//  Logging.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

let Log = Logger()

class Logger  {
    let nslogger : NSLogger = NSLogger()
    
    func log(message: String,
             level: Int,
             function: String = __FUNCTION__,
             file: String = __FILE__,
             line: Int = __LINE__) {
        nslogger.logWithFilename(file, lineNumber: Int32(line), functionName: function, domain: nil, level: Int32(level), message: message)
    }
}