//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <FacebookSDK/FacebookSDK.h>
#import <SwipeView/SwipeView.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Meteor/METDDPClient.h>

@interface METDDPClient (Private)

- (void)loginWithMethodName:(NSString *)methodName parameters:(NSArray *)parameters completionHandler:(METLogInCompletionHandler)completionHandler;

@end

@interface RACSignal (SwiftCompileFix)

- (RACSignal *)And;
- (RACSignal *)Or;
- (RACSignal *)Not;

+ (RACSignal *)Return:(id)object;

@end

@interface NSLogger : NSObject

- (void)logWithFilename:(NSString *)filename
             lineNumber:(int)lineNumber
           functionName:(NSString *)functionName
                 domain:(NSString *)domain
                  level:(int)level
                message:(NSString *)message;

@end