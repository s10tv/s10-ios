//
//  OnboardingViewManager.m
//  S10
//
//  Created by Tony Xiao on 11/2/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTView.h>
#import "Taylr-Swift.h"

@interface UIView (ReactPrivate)

- (void)reactAddControllerToClosestParent:(UIViewController *)controller;

@end

@interface TSContainerView : RCTView

@property (nonatomic, strong) UIViewController *vc;

@end

@implementation TSContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.vc = [[UIStoryboard storyboardWithName:@"Onboarding" bundle:nil] instantiateInitialViewController];
//        self.vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.vc.view];
    }
    return self;
}

//- (void)reactSetFrame:(CGRect)frame {
//    self.frame = frame;
//    self.vc.view.frame = self.bounds;
//}

//- (void)layoutSubviews {
////    [super layoutSubviews];
//    self.vc.view.frame = self.bounds;
//}

- (void)reactBridgeDidFinishTransaction {
    // we can't hook up the VC hierarchy in 'init' because the subviews aren't
    // hooked up yet, so we do it on demand here whenever a transaction has finished
    [self reactAddControllerToClosestParent:self.vc];
}

@end

@interface OnboardingViewManager : RCTViewManager

@end

@implementation OnboardingViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    UIView *view = [[TSContainerView alloc] initWithFrame:CGRectZero];
//    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}


RCT_EXPORT_METHOD(testMethod:(NSString *)string withAlt:(NSString *)altString) {
    
//    id x = [[LoginViewController alloc] init];
    
    NSLog(@"What's up with %@ alt: %@", string, altString);
}

@end