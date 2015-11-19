//
//  TSViewController.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(TSViewController, RCTViewManager)

RCT_EXTERN_METHOD(componentWillMount:(int)reactTag)
RCT_EXTERN_METHOD(componentDidMount:(int)reactTag)
RCT_EXTERN_METHOD(componentWillUnmount:(int)reactTag)
RCT_EXTERN_METHOD(componentDidUnmount:(int)reactTag)

@end

// App events:
// ViewController.pushRoute -> [String: AnyObject]
