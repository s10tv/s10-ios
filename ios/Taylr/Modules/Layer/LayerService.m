//
//  TSLayerService.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSLayerService, NSObject)

RCT_EXTERN_METHOD(connect:(RCTResponseSenderBlock)block)
RCT_EXTERN_METHOD(isAuthenticated:(RCTResponseSenderBlock)block)
RCT_EXTERN_METHOD(requestAuthenticationNonce:(RCTResponseSenderBlock)block)
RCT_EXTERN_METHOD(authenticate:(NSString *)identityToken block:(RCTResponseSenderBlock)block)
RCT_EXTERN_METHOD(deauthenticate:(RCTResponseSenderBlock)block)

@end

// MARK: - App Events
// Layer.didReceiveNonce -> String
// Layer.unreadCountUpdate -> Int

