//
//  TSConversationListView.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/UIView+React.h>
#import "Taylr-Swift.h"
#import "TSConversationListView.h"

@interface TSConversationListViewManager ()

@property (nonatomic, strong) LYRClient *layerClient;

@end

@implementation TSConversationListViewManager

RCT_EXPORT_MODULE()

- (instancetype)initWithLayerClient:(LYRClient *)layerClient {
    if (self = [super init]) {
        self.layerClient = layerClient;
    }
    return self;
}

- (UIView *)view {
    ConversationListViewController *vc = [[UIStoryboard storyboardWithName:@"Conversation" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationList"];
    vc.layerClient = self.layerClient;
    return vc.view;
}

@end
