//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "MarvelService.h"
#import "MarvelApiClient.h"
#import <CoreData/CoreData.h>
#import "User+CoreDataClass.h"

@interface MarvelServiceImpl()
@property(nonatomic, weak) id<MarvelApiClient> client;
@property(atomic, strong) NSPersistentContainer *container;
@property(atomic, assign) NSInteger limit;
@property(atomic, assign) NSInteger offset;
@property(atomic, assign) BOOL isLoading;
@property(atomic, assign) NSInteger lastResponseDataCount;
@property(atomic, assign) BOOL hasNext;
@property(nonatomic, copy) void(^loadCharactersCallback)(NSArray * _Nullable, NSError * _Nullable);
@end

@implementation MarvelServiceImpl
- (instancetype)initWith:(id <MarvelApiClient>)apiClient persistentContainer:(NSPersistentContainer *)container {
    self = [super init];
    if (self) {
        self.client = apiClient;
        self.container = container;
        self.limit = 30;
        self.offset = 0;
        self.hasNext = true;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.container.viewContext];
    }
    return self;
}

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *objects = notification.userInfo[NSInsertedObjectsKey];
    NSMutableArray *users = [NSMutableArray new];
    for (NSManagedObject *object in objects) {
        if ([object isKindOfClass:[User class]]) {
            [users addObject:object];
        }
    }
    if (users.count > 0) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifire" ascending:YES];
        NSArray *sorted = [users sortedArrayUsingDescriptors:@[sortDescriptor]];
        self.loadCharactersCallback(sorted, nil);
    }
}

- (BOOL)canLoadNext {
    return self.hasNext && !self.isLoading;
}

- (void)loadNextCharacters:(void (^)(NSArray * _Nullable, NSError * _Nullable))callback {
    if (![self canLoadNext]) {
        return;
    }
    self.loadCharactersCallback = callback;
    self.isLoading = true;
    [self.client getCharacters:self.offset limit:self.limit callback:^(NSArray * array, NSError * error) {
        if (!error) {
            self.hasNext = array.count == self.limit;
            self.offset += array.count;
            NSManagedObjectContext *context = [self.container newBackgroundContext];
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            context.undoManager = nil;
            NSError *error = nil;
            [self syncCharacters:array taskContext:context error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.loadCharactersCallback) {
                        self.loadCharactersCallback(nil, error);
                    }
                });
            }
            self.isLoading = false;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
                NSError *error = nil;
                NSArray *characters = [self.container.viewContext executeFetchRequest:fetchRequest error:&error];
                self.loadCharactersCallback(characters, error);
            });
        }
    }];
}

- (BOOL)syncCharacters:(NSArray *)characters taskContext:(NSManagedObjectContext *)context error:(NSError **)error {
    __block NSError *blockError = nil;
    __block BOOL success = NO;
    [context performBlockAndWait:^{
        NSMutableArray *ids = [NSMutableArray new];
        for (NSDictionary *character in characters) {
            [ids addObject:[NSString stringWithFormat:@"%ld", (long)[character[@"identifire"] integerValue]]];
        }
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifire IN %@", ids]];
        NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        if (@available(iOS 11.0, *)) {
            deleteRequest.resultType = NSPersistentHistoryResultTypeObjectIDs;
        } else {
            deleteRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
        }
        
        NSBatchDeleteResult *result = [context executeRequest:deleteRequest error:&blockError];
        if (blockError) {
            return;
        }
        id results = result.result;
        if (results) {
            [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey: results} intoContexts:@[self.container.viewContext]];
        }
        for (NSDictionary *userJson in characters) {
            [self createUser:userJson taskContext:context];
        }
        if (context.hasChanges) {
            [context save:&blockError];
            [context reset];
        }
        success = true;
    }];
    if (error != NULL) *error = blockError;
    return success;
}

- (User * _Nullable)createUser:(NSDictionary *)json taskContext:(NSManagedObjectContext *)context {
    User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user setIdentifire:[NSString stringWithFormat:@"%li", (long)[json[@"id"] integerValue]]];
    [user setName:json[@"name"]];
    NSDictionary *thumb = json[@"thumbnail"];
    [user setThumbURL:[NSString stringWithFormat:@"%@/standard_medium.%@", thumb[@"path"], thumb[@"extension"]]];
    return user;
}
@end
