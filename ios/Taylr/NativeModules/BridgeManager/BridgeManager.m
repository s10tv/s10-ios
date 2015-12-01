//
//  BridgeManager.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSBridgeManager, NSObject)

RCT_EXTERN_METHOD(registerForPushNotifications)
RCT_EXTERN_METHOD(reloadBridge)
RCT_EXTERN_METHOD(setDebugBuildsEnabled:(BOOL)debugBuildsEnabled)

@end
