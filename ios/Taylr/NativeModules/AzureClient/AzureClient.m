//
//  AzureClient.m
//  Taylr
//
//  Created by Tony Xiao on 11/30/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSAzureClient, NSObject)

RCT_EXTERN_REMAP_METHOD(putAsync,
                        put:(NSURL *)remoteURL localURL:(NSURL *)localURL contentType:(NSString *)contentType resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
