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
RCT_EXTERN_METHOD(setUserUsername:(NSString *)username)
RCT_EXTERN_METHOD(setUserPhone:(NSString *)phone)
RCT_EXTERN_METHOD(setUserEmail:(NSString *)email)
RCT_EXTERN_METHOD(setUserFirstName:(NSString *)firstName)
RCT_EXTERN_METHOD(setUserLastName:(NSString *)lastName)
RCT_EXTERN_METHOD(setUserFullname:(NSString *)fullname)
RCT_EXTERN_METHOD(setUserDisplayName:(NSString *)displayName)
RCT_EXTERN_METHOD(setUserAvatarURL:(NSURL *)avatarURL)
RCT_EXTERN_METHOD(setUserCoverURL:(NSURL *)coverURL)

// constantsToExport

@end
