//
//  Session.m
//  Taylr
//
//  Created by Tony Xiao on 11/29/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSSession, NSObject)

RCT_EXTERN_METHOD(login:(nonnull NSString *)userId resumeToken:(nonnull NSString *)resumeToken tokenExpiry:(NSDate *)tokenExpiry)
RCT_EXTERN_METHOD(logout)
RCT_EXTERN_METHOD(setUsername:(NSString *)username)
RCT_EXTERN_METHOD(setPhone:(NSString *)phone)
RCT_EXTERN_METHOD(setEmail:(NSString *)email)
RCT_EXTERN_METHOD(setFirstName:(NSString *)firstName)
RCT_EXTERN_METHOD(setLastName:(NSString *)lastName)
RCT_EXTERN_METHOD(setFullname:(NSString *)fullname)
RCT_EXTERN_METHOD(setDisplayName:(NSString *)displayName)
RCT_EXTERN_METHOD(setAvatarURL:(NSURL *)avatarURL)
RCT_EXTERN_METHOD(setCoverURL:(NSURL *)coverURL)

// constantsToExport

@end
