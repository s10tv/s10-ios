//
//  TSAnalytics.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSAnalytics, NSObject)

RCT_EXTERN_METHOD(identifyDevice:(NSString *)deviceId)
RCT_EXTERN_METHOD(identifyUser:(NSString *)userId)
RCT_EXTERN_METHOD(setUserFullname:(NSString *)fullname)
RCT_EXTERN_METHOD(track:(NSString *)event properties:(NSDictionary *)properties)
RCT_EXTERN_METHOD(setUserProperty:(NSString *)name value:(NSString *)value)
RCT_EXTERN_METHOD(incrementUserProperty:(NSString *)name amount:(int)amount)

@end
