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
@property (nonatomic, strong) NSString *storyboard;


@end

@implementation TSContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.vc = [[UIStoryboard storyboardWithName:@"Onboarding" bundle:nil] instantiateInitialViewController];
////        self.vc.view.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:self.vc.view];
    }
    return self;
}

- (instancetype)initWithStoryboard:(NSString *)storyboardName identifier:(NSString *)identifier {
    if (self = [super initWithFrame:CGRectZero]) {
        self.storyboard = storyboardName;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        self.vc = (identifier != nil) ? [storyboard instantiateViewControllerWithIdentifier:identifier]
        : [storyboard instantiateInitialViewController];
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

RCT_EXPORT_VIEW_PROPERTY(storyboard, NSString)

- (UIView *)view {
    UIView *view = [[TSContainerView alloc] initWithFrame:CGRectZero];
//    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (UIView *)viewWithProps:(NSDictionary *)props {
    return [[TSContainerView alloc] initWithStoryboard:props[@"storyboard"] identifier:props[@"identifier"]];
}


RCT_EXPORT_METHOD(testMethod:(NSString *)string withAlt:(NSString *)altString) {
    
//    id x = [[LoginViewController alloc] init];
    
    NSLog(@"What's up with %@ alt: %@", string, altString);
}

@end