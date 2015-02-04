//
//  Serendipity-Bridging.m
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

#import <NSLogger/LoggerClient.h>
#import "Serendipity-Bridging-Header.h"

@implementation RACSignal (SwiftCompileFix)

- (RACSignal *)And {
    return [self and];
}
- (RACSignal *)Or {
    return [self or];
}
- (RACSignal *)Not {
    return [self not];
}

+ (RACSignal *)Return:(id)object {
    return [self return:object];
}

@end

@implementation NSLogger {
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

- (void)logWithFilename:(NSString *)filename
             lineNumber:(int)lineNumber
           functionName:(NSString *)functionName
                 domain:(NSString *)domain
                  level:(int)level
                message:(NSString *)message {
    LogMessageToF(_logger, filename.UTF8String, lineNumber, functionName.UTF8String, domain, level, @"%@", message);
}

@end