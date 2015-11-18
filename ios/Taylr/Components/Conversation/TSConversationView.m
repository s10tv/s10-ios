//
//  TSConversationView.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/UIView+React.h>
#import "Taylr-Swift.h"
#import "TSConversationView.h"

@interface TSConversationViewManager ()

@property (nonatomic, strong) LYRClient *layerClient;

@end

@implementation TSConversationViewManager

RCT_EXPORT_MODULE()

- (instancetype)initWithLayerClient:(LYRClient *)layerClient {
    if (self = [super init]) {
        self.layerClient = layerClient;
    }
    return self;
}

- (UIView *)view {
    ConversationViewController *vc = [[UIStoryboard storyboardWithName:@"Conversation" bundle:nil] instantiateViewControllerWithIdentifier:@"Conversation"];
    vc.layerClient = self.layerClient;
    return vc.view;
}

@end
