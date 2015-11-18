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

RCT_EXTERN_METHOD(getUnreadCount:(RCTResponseSenderBlock *)callback)

@end
