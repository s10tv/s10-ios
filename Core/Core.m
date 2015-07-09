//
//  Core.m
//  S10
//
//  Created by Tony Xiao on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

#ifdef DEBUG
#import <NSLogger/LoggerClient.h>
#endif
#import "Core.h"

@implementation NSLogger

#ifdef DEBUG
{
    Logger *_logger;
}

- (instancetype)init {
    if (self = [super init]) {
        _logger = LoggerInit();
        LoggerSetOptions(_logger, kLoggerOption_BufferLogsUntilConnection
                         |kLoggerOption_BrowseBonjour
                         |kLoggerOption_BrowseOnlyLocalDomain);
        LoggerStart(_logger);
    }
    return self;
}
#endif

- (void)logWithFilename:(NSString *)filename
             lineNumber:(int)lineNumber
           functionName:(NSString *)functionName
                 domain:(NSString *)domain
                  level:(int)level
                message:(NSString *)message {
#ifdef DEBUG
    LogMessageToF(_logger, filename.UTF8String, lineNumber, functionName.UTF8String, domain, level, @"%@", message);
#endif
}

@end

//@implementation Bugfender (Swift)
//
//+ (void)logWithFilename:(NSString *)filename
//             lineNumber:(int)lineNumber
//           functionName:(NSString *)functionName
//                    tag:(NSString *)tag
//                  level:(BFLogLevel)level
//                message:(NSString *)message {
//    __BFLog(lineNumber, functionName, filename, level, tag, message);
//}
//
//@end

//@implementation Crashlytics (Swift)
//
//+ (void)logMessage:(NSString *)message {
//    CLSLog(@"%@", message);
//}
//
//@end