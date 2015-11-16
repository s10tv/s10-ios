//
//  TestNSObject.m
//  S10
//
//  Created by Tony Xiao on 7/13/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTests-bridging-header.h"

@implementation TestNSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.strValue = @"TestStr";
        self.intValue = 25;
    }
    return self;
}

@end