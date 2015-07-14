//
//  CoreTests-bridging-header.h
//  S10
//
//  Created by Qiming Fang on 6/19/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

#ifndef S10_CoreTests_bridging_header_h
#define S10_CoreTests_bridging_header_h

#import <OHHTTPStubs/OHHTTPStubs.h>

@interface TestNSObject : NSObject

@property (nonatomic, strong) NSString *strValue;
@property (nonatomic, assign) int intValue;

@end

#endif
