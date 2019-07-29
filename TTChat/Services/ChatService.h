//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatSocket.h"
#import "User+CoreDataClass.h"
#import "Chat+CoreDataClass.h"
#import "Message+CoreDataClass.h"
@class NSPersistentContainer;

NS_ASSUME_NONNULL_BEGIN

@protocol ChatService <NSObject>
- (void)connect:(NSString *)chatId;
- (void)disconnect;
- (void)getChat:(NSString *)chatId;
- (void)sendMessage:(NSString *)text chatId:(NSString *)chatId;
@end

@interface ChatServiceImpl : NSObject<ChatService, ChatDelegate>
- (instancetype)initWithSocket:(id<ChatSocket>)socket persistantContainer:(NSPersistentContainer *)container;
@end

NS_ASSUME_NONNULL_END
