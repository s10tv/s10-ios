//
//  TSConversationView.m
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(TSConversationViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(currentUser, userViewModel)
RCT_EXPORT_VIEW_PROPERTY(conversationId, NSString)

@end
