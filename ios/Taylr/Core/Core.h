//
//  Core.h
//  Core
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSLogger : NSObject

- (void)logWithFilename:(NSString *)filename
             lineNumber:(int)lineNumber
           functionName:(NSString *)functionName
                 domain:(NSString *)domain
                  level:(int)level
                message:(NSString *)message;

@end
