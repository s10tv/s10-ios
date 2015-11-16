//
//  TaylrAPI.m
//  S10
//
//  Created by Tony Xiao on 11/2/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TaylrAPI, NSObject)

RCT_EXTERN_METHOD(getMeteorUser:(RCTResponseSenderBlock *)callback)

@end
