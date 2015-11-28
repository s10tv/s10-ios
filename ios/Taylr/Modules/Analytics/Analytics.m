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

RCT_EXTERN_METHOD(userDidLogin:(NSString *)userId isNewUser:(BOOL)isNewUser)
RCT_EXTERN_METHOD(userDidLogout)
RCT_EXTERN_METHOD(setUserUsername:(NSString *)username)
RCT_EXTERN_METHOD(setUserPhone:(NSString *)phone)
RCT_EXTERN_METHOD(setUserEmail:(NSString *)email)
RCT_EXTERN_METHOD(setUserFullname:(NSString *)fullname)
RCT_EXTERN_METHOD(track:(NSString *)event properties:(NSDictionary *)properties)
RCT_EXTERN_METHOD(screen:(NSString *)name properties:(NSDictionary *)properties)
RCT_EXTERN_METHOD(setUserProperty:(NSString *)name value:(NSString *)value)
RCT_EXTERN_METHOD(flush)

@end
