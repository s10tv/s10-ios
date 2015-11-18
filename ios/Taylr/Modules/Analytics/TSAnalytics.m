//
//  TSAnalytics.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "Taylr-Swift.h"

@interface TSAnalytics : NSObject <RCTBridgeModule>

@end

@implementation TSAnalytics

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(track:(NSString *)event properties:(NSString *)properties) {
    RCTLogInfo(@"Track event %@ properties %@", event, properties);
}

@end