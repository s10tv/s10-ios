//
//  MuteChecker.swift
//  Animations
//
//  Created by Tony Xiao on 8/4/15.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "MuteChecker.h"

@interface MuteChecker ()

@property (nonatomic, strong) MuteCheckCompletionHandler completionBlock;
@property (nonatomic, assign) SystemSoundID soundId;
@property (nonatomic, strong) NSDate* startTime;

- (void)completed;

@end

static SystemSoundID kInvalidSoundId = -1;

void MuteCheckCompletionFunc(SystemSoundID ssID, void* clientData);
void MuteCheckCompletionFunc(SystemSoundID ssID, void* clientData) {
	MuteChecker *obj = (__bridge MuteChecker *)clientData;
	[obj completed];
}

@implementation MuteChecker

- (instancetype)init {
	if (self = [super init]) {
        _soundId = kInvalidSoundId;
    }
	return self;
}

- (void)dealloc {
	if (self.soundId != kInvalidSoundId) {
        AudioServicesRemoveSystemSoundCompletion(self.soundId);
        AudioServicesDisposeSystemSoundID(self.soundId);
    }
}

#pragma mark - 

- (void)playMuteSound:(MuteCheckCompletionHandler)completionBlock {
    self.startTime = [NSDate date];
    self.completionBlock = completionBlock;
    AudioServicesPlaySystemSound(self.soundId);
}

- (void)completed {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startTime];
    BOOL muted = (interval > 0.1) ? NO : YES;
    self.completionBlock(muted);
    self.completionBlock = nil;
}

#pragma mark -

- (void)check:(MuteCheckCompletionHandler)completionBlock {
    if (self.soundId == kInvalidSoundId) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"MuteChecker" withExtension:@"caf"];
        if (AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_soundId) == kAudioServicesNoError) {
            AudioServicesAddSystemSoundCompletion(self.soundId, CFRunLoopGetMain(), kCFRunLoopDefaultMode,
                                                  MuteCheckCompletionFunc, (__bridge void *)(self));
            UInt32 yes = 1;
            AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(_soundId), &_soundId, sizeof(yes), &yes);
        }
    }
    if (self.startTime == nil) {
        [self playMuteSound:completionBlock];
    } else {
        NSDate *now = [NSDate date];
        NSTimeInterval lastCheck = [now timeIntervalSinceDate:self.startTime];
        if (lastCheck > 1) {	//prevent checking interval shorter then the sound length
            [self playMuteSound:completionBlock];
        }
    }
}

#pragma mark -

+ (void)check:(MuteCheckCompletionHandler)completionBlock {
    MuteChecker *checker = [[MuteChecker alloc] init];
    [checker check:^(BOOL muted) {
        MuteChecker *retainedChecker = checker; // Retain until callback is done
        completionBlock(muted);
        retainedChecker = nil;
    }];
}

@end
