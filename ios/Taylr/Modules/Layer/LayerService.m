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

RCT_EXTERN_REMAP_METHOD(connectAsync,
                        connect:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_REMAP_METHOD(isAuthenticatedAsync,
                        isAuthenticated:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_REMAP_METHOD(requestAuthenticationNonceAsync,
                        requestAuthenticationNonce:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_REMAP_METHOD(authenticateAsync,
                        authenticate:(NSString *)identityToken resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_REMAP_METHOD(deauthenticateAsync,
                        deauthenticate:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end

// MARK: - App Events
// Layer.didReceiveNonce -> String
// Layer.unreadCountUpdate -> Int

