//
//  TSNavigationManager.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSBridgeManager, NSObject)

RCT_EXTERN_REMAP_METHOD(uploadToAzureAsync,
                        uploadToAzure:(NSURL *)remoteURL localURL:(NSURL *)localURL contentType:(NSString *)contentType resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_REMAP_METHOD(getDefaultAccountAsync,
                        getDefaultAccount:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setDefaultAccount:(METAccount *)account)

@end
