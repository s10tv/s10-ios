//
//  Serendipity-Bridging.m
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

#import "Serendipity-Bridging-Header.h"

@implementation RACSignal (SwiftCompileFix)

- (RACSignal *)And {
    return [self and];
}
- (RACSignal *)Or {
    return [self or];
}
- (RACSignal *)Not {
    return [self not];
}

+ (RACSignal *)Return:(id)object {
    return [self return:object];
}

@end