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

RCT_EXTERN_METHOD(userDidLogin:(BOOL)isNewUser)
RCT_EXTERN_METHOD(userDidLogout)
RCT_EXTERN_METHOD(updateUsername)
RCT_EXTERN_METHOD(updatePhone)
RCT_EXTERN_METHOD(updateEmail)
RCT_EXTERN_METHOD(updateFullname)
RCT_EXTERN_METHOD(track:(nonnull NSString *)event properties:(NSDictionary *)properties)
RCT_EXTERN_METHOD(screen:(nonnull NSString *)name properties:(NSDictionary *)properties)
RCT_EXTERN_METHOD(setUserProperties:(NSDictionary *)properties)
RCT_EXTERN_METHOD(flush)

@end
