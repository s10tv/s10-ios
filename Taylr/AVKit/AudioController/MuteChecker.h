//
//  MuteChecker.swift
//  Animations
//
//  Created by Tony Xiao on 8/4/15.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

#import <Foundation/Foundation.h>

/// this class must use with a MuteChecker.caf (a 0.2 sec mute sound) in Bundle
typedef void (^MuteCheckCompletionHandler)(BOOL muted);

@interface MuteChecker : NSObject

- (void)check:(MuteCheckCompletionHandler)completionBlock;

+ (void)check:(MuteCheckCompletionHandler)completionBlock;

@end
