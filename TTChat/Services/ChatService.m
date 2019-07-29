//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ChatService.h"
#import <CoreData/CoreData.h>
#import "Consts.h"

@interface ChatServiceImpl()
@property(nonatomic, weak) id<ChatSocket> socket;
@property(nonatomic, strong) NSPersistentContainer *container;
@property(strong, nonnull) dispatch_queue_t serialQueue;;
@end

@implementation ChatServiceImpl
- (instancetype)initWithSocket:(id<ChatSocket>)socket persistantContainer:(NSPersistentContainer *)container {
    self = [super init];
    if (self) {
        self.socket = socket;
        self.socket.delegate = self;
        self.container = container;
        self.serialQueue = dispatch_queue_create("messageQueue", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.container.viewContext];
    }
    return self;
}

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *objects = notification.userInfo[NSInsertedObjectsKey];
    for (NSManagedObject *object in objects) {
        if ([object isKindOfClass:[Chat class]]) {
            Chat *chat = (Chat *)object;
            NSArray *messages = [chat.messages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:NO]]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatEnabled object:self userInfo:@{@"result": messages}];
        } else if ([object isKindOfClass:[Message class]]) {
            Message *message = (Message *)object;
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageRescived object:self userInfo:@{@"result": message}];
        }
    }
}

- (BOOL)createMessage:(NSString *)text inChat:(NSString *)chatId isOwner:(BOOL)isOwner taskContext:(NSManagedObjectContext *)context error:(NSError **)error {
    __block NSError *blockError = nil;
    __block BOOL success = NO;
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Chat"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifire == %@", chatId]];
        NSArray *results = [context executeFetchRequest:fetchRequest error:&blockError];
        if (results.count > 0) {
            Chat *chat = results.firstObject;
            Message *message = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
            [message setText:text];
            [message setIdentifire:[[NSUUID UUID] UUIDString]];
            [message setIsOwner:isOwner];
            [message setTs:[NSDate date]];
            [chat addMessagesObject:message];
            [message setChat:chat];
            
            if (context.hasChanges) {
                [context save:&blockError];
                [context reset];
            }
            success = YES;
        }
    }];
    if (error != NULL) *error = blockError;
    return success;
}

- (BOOL)createChat:(NSString *)chatId taskContext:(NSManagedObjectContext *)context error:(NSError **)error {
    __block NSError *blockError = nil;
    __block BOOL success = NO;
    [context performBlockAndWait:^{
        Chat *chat = (Chat *)[NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:context];
        [chat setIdentifire:chatId];
        if (context.hasChanges) {
            [context save:&blockError];
            [context reset];
        }
        success = YES;
    }];
    if (error != NULL) *error = blockError;
    return success;
}

//#pragma mark - ChatService
- (User * _Nullable)getUser:(NSString *)usrId error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifire == %@", usrId]];

    NSArray *results = [self.container.viewContext executeFetchRequest:fetchRequest error:error];
    if (results.count > 0) {
        return [results lastObject];
    }
    return nil;
}

- (Chat *)fetchChat:(NSString *)chatId error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Chat"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifire == %@", chatId]];
    NSArray *results = [self.container.viewContext executeFetchRequest:fetchRequest error:error];
    Chat *chat = nil;
    if (results > 0) {
        chat = (Chat *)[results firstObject];
    }
    return chat;
}

- (void)connect:(NSString *)chatId {
    dispatch_async(self.serialQueue, ^{
        [self.socket connect];
    });
}

- (void)disconnect {
    dispatch_async(self.serialQueue, ^{
        [self.socket disconnect];
    });
}


- (void)getChat:(nonnull NSString *)chatId {
    NSError *error = nil;
    Chat *chat = [self fetchChat:chatId error:&error];
    if (chat != nil) {
        NSArray *messages = [chat.messages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:NO]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatEnabled object:self userInfo:@{@"result": messages}];
        return;
    }
    User *user = [self getUser:chatId error:&error];
    dispatch_async(self.serialQueue, ^{
        [self.socket createChat:chatId userName:user.name];
    });
}


- (void)sendMessage:(nonnull NSString *)text chatId:(nonnull NSString *)chatId {
    dispatch_async(self.serialQueue, ^{
        NSError *error = nil;
        NSManagedObjectContext *taskContext = [self.container newBackgroundContext];
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        taskContext.undoManager = nil;
        [self createMessage:NSLocalizedString(text, @"") inChat:chatId isOwner:YES taskContext:taskContext error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    });
    dispatch_async(self.serialQueue, ^{
        [self.socket sendMessage:text chatId:chatId];
    });
}

#pragma mark - SocketDelegate
- (void)chatCreated:(nonnull NSString *)chatId {
    NSError *error = nil;
    NSManagedObjectContext *taskContext = [self.container newBackgroundContext];
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    taskContext.undoManager = nil;
    [self createChat:chatId taskContext:taskContext error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)resciveMessage:(NSString *)message messageId:(NSString *)messageId chat:(NSString *)chatId {
    NSError *error = nil;
    NSManagedObjectContext *taskContext = [self.container newBackgroundContext];
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    taskContext.undoManager = nil;
    [self createMessage:message inChat:chatId isOwner:NO taskContext:taskContext error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)connected {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionSucceeded object:self];
    });
}

- (void)disconnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionFulfilled object:self];
    });
}
@end
