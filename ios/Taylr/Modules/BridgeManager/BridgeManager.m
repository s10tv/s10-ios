//
//  TSNavigationManager.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(TSBridgeManager, NSObject)

RCT_EXTERN_METHOD(uploadToAzure:(NSURL *)remoteURL localURL(NSURL *):localURL contentType:(NSString *)contentType block:(RCTResponseSenderBlock)block)

@end
