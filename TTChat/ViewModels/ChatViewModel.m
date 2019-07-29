//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ChatViewModel.h"
#import "AppCoordinator.h"
#import "Consts.h"
#import "Message+CoreDataClass.h"

@interface ChatViewModel()
@property(strong) id<ChatService> service;
@property(strong) id<Imageloader> imageLoader;
@property(nonatomic, strong) NSString *chatId;
@end

@implementation ChatViewModel
- (instancetype)initWith:(id<ChatService>)service imageLoader:(id<Imageloader>)imageLoader userId:(nonnull NSString *)useId  {
    self = [super init];
    if (self) {
        self.service = service;
        self.chatId = useId;
    }
    return self;
}

- (void)subscribeOnNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatEnabled:) name:kChatEnabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected:) name:kConnectionSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disConnected:) name:kConnectionFulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resciveMessage:) name:kChatMessageRescived object:nil];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatEnabled object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConnectionSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConnectionFulfilled object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageRescived object:nil];
}

- (void)connect {
    [self subscribeOnNotifications];
    [self.service connect:self.chatId];
}

- (void)disconnect {
    [self unsubscribeFromNotifications];
}

- (void)selectQuestion:(NSString *)question {
    [self.service sendMessage:question chatId:self.chatId];
}

- (NSArray *)getQuestions {
    return @[
                kQuestionHowAreYou,
                kQuestionWhatIsYourFavoritMovie,
                kQuestionWhereDoYouFrom,
                kQuestionDoYouLikeLastAvengersMovie,
                kQuestionWhoIsTheStrongestSuperheroInTheWorld
            ];
}

#pragma mark - Observer

- (void)connected:(NSNotification *)notification {
    [self.service getChat:self.chatId];
}

- (void)disConnected:(NSNotification *)notification {
    //TODO handle
}

- (void)resciveMessage:(NSNotification *)notification {
    Message *message = notification.userInfo[@"result"];
    if (message.isOwner) {
        if ([self.delegate respondsToSelector:@selector(pushOwnerMessage:)]) {
            [self.delegate pushOwnerMessage:message.text];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(pushCharacterMessage:)]) {
            [self.delegate pushCharacterMessage:message.text];
        }
    }
}

- (void)chatEnabled:(NSNotification *)notification {
    NSArray *messages = notification.userInfo[@"result"];
    NSMutableArray *array = [NSMutableArray new];
    for (Message *message in messages) {
        [array addObject:@{@"text": message.text, @"owner": @(message.isOwner)}];
    }
    if ([self.delegate respondsToSelector:@selector(connectionSucceeded:)]) {
        [self.delegate connectionSucceeded:array];
    }
}
@end
