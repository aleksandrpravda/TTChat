//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ChatService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatDelegate <NSObject>
- (void)connected;
- (void)disconnected;
@optional
- (void)chatCreated:(NSString *)chatId;
- (void)resciveMessage:(NSString *)message messageId:(NSString *)messageId chat:(NSString *)chatId;
@end

@protocol ChatSocket <NSObject>
@property(nonatomic, weak) id<ChatDelegate> delegate;
@property(nonatomic, readonly) BOOL isConnected;
- (void)connect;
- (void)disconnect;
- (void)createChat:(NSString *)chatId userName:(NSString *)name;
- (void)sendMessage:(NSString *)message chatId:(NSString *)chatId;
@end

@interface ChatSocketImpl : NSObject<ChatSocket>
@end

NS_ASSUME_NONNULL_END
