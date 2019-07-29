//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ServerSideSimulator.h"
#import "Consts.h"
#include "AnswerGenerator.h"

@implementation ServerSideSimulator
- (instancetype)init {
    self = [super init];
    if (self) {
        [self subscribeOnNotifications];
    }
    return self;
}

- (void)subscribeOnNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connect:) name:kConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disConnect:) name:kDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createChatRoom:) name:kCreateChatRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:kSendMessageNotification object:nil];
}

- (void)connect:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectedNotification object:nil userInfo:@{@"result": @"connected"}];
}

- (void)disConnect:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisconnectedNotification object:nil userInfo:@{@"result": @"disConnected"}];
}

- (void)createChatRoom:(NSNotification *)notification {
    NSString *chatId = notification.userInfo[@"chatId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomCreatedNotification object:nil userInfo:@{@"result": @{@"chatId": chatId}}];
    NSString *name = notification.userInfo[@"name"];
    NSString *messageId = [[NSUUID UUID] UUIDString];
    NSString *answerMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(kGreating, @""), name];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageNotification object:nil userInfo:@{@"result": @{@"message": answerMessage, @"chatId": chatId, @"messageId": messageId}}];
}

- (void)sendMessage:(NSNotification *)notification {
    NSString *message = notification.userInfo[@"message"];
    NSString *messageId = [[NSUUID UUID] UUIDString];
    NSString *chatId = notification.userInfo[@"chatId"];
    
    id answerMessage = [AnswerGenerator getUnswerForQuestion:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageNotification object:nil userInfo:@{@"result": @{@"message": answerMessage, @"chatId": chatId, @"messageId": messageId}}];
}
@end
