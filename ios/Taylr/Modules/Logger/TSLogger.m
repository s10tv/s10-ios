//
//  TSLogger.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSLogger, NSObject)

RCT_EXTERN_METHOD(log:(NSString *)logText level:(NSString *)level function:(NSString *)function file:(NSString *)file line:(int)line)

@end
