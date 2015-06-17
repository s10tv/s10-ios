//
//  Core.h
//  Core
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Meteor/METDatabase.h>

//! Project version number for Backend.
FOUNDATION_EXPORT double CoreVersionNumber;

//! Project version string for Backend.
FOUNDATION_EXPORT const unsigned char CoreVersionString[];

@interface METDatabase (Private)

- (void)reset;

@end

@interface RACSignal (SwiftCompileFix)

- (RACSignal *)And;
- (RACSignal *)Or;
- (RACSignal *)Not;

+ (RACSignal *)Return:(id)object;

@end

@interface NSLogger : NSObject

- (void)logWithFilename:(NSString *)filename
             lineNumber:(int)lineNumber
           functionName:(NSString *)functionName
                 domain:(NSString *)domain
                  level:(int)level
                message:(NSString *)message;

@end

//@interface Bugfender (Swift)
//
//+ (void)logWithFilename:(NSString *)filename
//             lineNumber:(int)lineNumber
//           functionName:(NSString *)functionName
//                    tag:(NSString *)tag
//                  level:(BFLogLevel)level
//                message:(NSString *)message;
//
//@end

//@interface Crashlytics (Swift)
//
//+ (void)logMessage:(NSString *)message;
//
//@end