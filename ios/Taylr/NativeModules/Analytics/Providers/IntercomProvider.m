//
//  IntercomProvider.m
//  Taylr
//
//  Created by Tony Xiao on 11/24/15.
//  Copyright © 2015 S10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TSIntercomProvider, NSObject)

RCT_EXTERN_METHOD(setHMAC:(NSString*)hmac data:(NSString *)data)
RCT_EXTERN_METHOD(presentMessageComposer)
RCT_EXTERN_METHOD(presentConversationList)

@end
