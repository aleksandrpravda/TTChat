//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ChatSocket.h"
#import "ServerSideSimulator.h"
#import "ChatService.h"
#import "Consts.h"
@interface ChatSocketImpl()
@property(nonatomic) BOOL isConnected;
@property(nonatomic, strong) dispatch_queue_t queue;
@end

@implementation ChatSocketImpl
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("server_queue", DISPATCH_QUEUE_SERIAL);
        [self subscribeOnNotifications];
    }
    return self;
}

- (void)subscribeOnNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected:) name:kConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:kDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomCreated:) name:kChatRoomCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(message:) name:kMessageNotification object:nil];
}

- (void)connect {
    dispatch_async(self.queue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectNotification object:nil];
    });
}

- (void)disconnect{
    dispatch_async(self.queue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisconnectNotification object:nil];
    });
}

- (void)createChat:(NSString *)chatId userName:(NSString *)name {
    dispatch_async(self.queue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kCreateChatRoomNotification object:nil userInfo:@{@"chatId": chatId, @"name": name}];
    });
}

- (void)sendMessage:(NSString *)message chatId:(NSString *)chatId {
    dispatch_async(self.queue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendMessageNotification object:nil userInfo:@{@"message": message, @"chatId": chatId}];
    });
}

- (BOOL)validConnection {
    if (!self.isConnected) {
        NSLog(@"User not connected");
    }
    return self.isConnected;
}

#pragma mark - SocketDelegate

- (void)connected:(NSNotification *)notification {
    self.isConnected = true;
    if ([self.delegate respondsToSelector:@selector(connected)]) {
        [self.delegate connected];
    }
}

- (void)disconnected:(NSNotification *)notification {
    self.isConnected = false;
    if ([self.delegate respondsToSelector:@selector(disconnected)]) {
        [self.delegate disconnected];
    }
}

- (void)roomCreated:(NSNotification *)notification {
    if (![self validConnection]) {
        return;
    }
    NSString *chatId = notification.userInfo[@"result"][@"chatId"];
    if ([self.delegate respondsToSelector:@selector(chatCreated:)]) {
        [self.delegate chatCreated:chatId];
    }
}

- (void)message:(NSNotification *)notification {
    if (![self validConnection]) {
        return;
    }
    NSString *message = notification.userInfo[@"result"][@"message"];
    NSString *messageID = notification.userInfo[@"result"][@"messageId"];
    NSString *chatId = notification.userInfo[@"result"][@"chatId"];
    if ([self.delegate respondsToSelector:@selector(resciveMessage: messageId: chat:)]) {
        [self.delegate resciveMessage:message messageId:messageID chat:chatId];
    }
}

@end

