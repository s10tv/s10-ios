//
//  TSConversationListView.h
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <React/RCTViewManager.h>
#import <LayerKit/LayerKit.h>

@interface TSConversationListViewManager : RCTViewManager

- (instancetype)initWithLayerClient:(LYRClient *)layerClient;

@end
