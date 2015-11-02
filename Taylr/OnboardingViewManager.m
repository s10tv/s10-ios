//
//  OnboardingViewManager.m
//  S10
//
//  Created by Tony Xiao on 11/2/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "Taylr-Swift.h"

@interface OnboardingViewManager : NSObject <RCTBridgeModule>

@end

@implementation OnboardingViewManager

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(testMethod:(NSString *)string withAlt:(NSString *)altString) {
    
    id x = [[LoginViewController alloc] init];
    
    NSLog(@"What's up with %@ alt: %@", string, altString);
}

@end