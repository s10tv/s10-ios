//
//  TSContainerView.m
//  S10
//
//  Created by Tony Xiao on 11/2/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTView.h>
#import <React/UIView+React.h>
#import "Taylr-Swift.h"

@interface TSContainerViewManager : RCTViewManager
@end

@interface TSContainerView : RCTView

@property (nonatomic, strong) NSString *sbName;
@property (nonatomic, strong) NSString *vcIdentifier;

@property (nonatomic, strong) UIViewController *vc;

@end

@implementation TSContainerViewManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(sbName, NSString)
RCT_EXPORT_VIEW_PROPERTY(vcIdentifier, NSString)

- (UIView *)view {
    return [[TSContainerView alloc] init];
}

@end

@implementation TSContainerView

- (void)dealloc {
    [self.vc willMoveToParentViewController:nil];
    [self.vc removeFromParentViewController];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil && self.vc == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.sbName bundle:nil];
        self.vc = (self.vcIdentifier != nil)
                ? [storyboard instantiateViewControllerWithIdentifier:self.vcIdentifier]
                : [storyboard instantiateInitialViewController];
        [self addSubview:self.vc.view];
        // Optimistically add, hopefully allowing viewWillAppear: to be invoked
        [self reactAddControllerToClosestParent:self.vc];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow != nil) {
        // Optimistically add, hopefully allowing viewWillAppear: to be invoked
        [self reactAddControllerToClosestParent:self.vc];
    }
}

- (void)didMoveToWindow {
    if (self.window != nil) {
        [self reactAddControllerToClosestParent:self.vc];
        NSAssert(self.vc.parentViewController != nil, @"ParentVC should not be nil");
    }
}

- (void)reactBridgeDidFinishTransaction {
    // Optimistically add, hopefully allowing viewWillAppear: to be invoked
    // NOTE: Unfortunately it's not always guaranteed, so any contained viewController will
    // need to be able to handle viewDidAppear: being called viewWillAppear and not have any bugs
    // which depends on viewWillAppear being called. In other words it should be a strict optimization
    [self reactAddControllerToClosestParent:self.vc];
}

@end
