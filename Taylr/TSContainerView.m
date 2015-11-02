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

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil && self.vc == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.sbName bundle:nil];
        self.vc = (self.vcIdentifier != nil)
                ? [storyboard instantiateViewControllerWithIdentifier:self.vcIdentifier]
                : [storyboard instantiateInitialViewController];
        [self addSubview:self.vc.view];
    }
    if (newSuperview == nil) {
        [self.vc willMoveToParentViewController:nil];
    }
}

- (void)didMoveToSuperview {
    if (self.superview == nil) {
        [self.vc removeFromParentViewController];
    }
}

- (void)reactBridgeDidFinishTransaction {
    [self reactAddControllerToClosestParent:self.vc];
}

@end
