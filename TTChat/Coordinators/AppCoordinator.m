//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "AppCoordinator.h"
#import "ChatSocket.h"
#import "MarvelApiClient.h"
#import "CharactersViewModel.h"
#import "CharactersViewController.h"
#import "MarvelService.h"
#import "ChatViewController.h"
#import "ChatViewModel.h"
#import "ChatService.h"
#import "ImageLoader.h"

@interface AppCoordinator() <AppCoordinatorDelegate>
@property(strong, nonatomic) UIWindow *window;
@property(readonly, strong) UINavigationController *rootViewController;
@property(readonly, strong) ChatSocketImpl *chatSocket;
@property(readonly, strong) MarvelApiClientImpl *apiClient;
@property(readonly, strong) NSPersistentContainer *persistentContainer;
@property(readonly, strong) CharactersViewModel *charactersViewModel;
@property(readonly, strong) ImageloaderImpl *imageLoader;
@property(strong) ChatViewModel *chatViewModel;
@end

@implementation AppCoordinator
- (instancetype)initWith:(UIWindow *)window {
    self = [super init];
    if (self) {
        self.window = window;
    }
    return self;
}

- (void)start {
    if (!self.window) {
        return;
    }
    [self.window setRootViewController:self.rootViewController];
    [self.window makeKeyAndVisible];
    CharactersViewController *viewController = [[CharactersViewController alloc] initWith:self.charactersViewModel];
    [self.rootViewController pushViewController:viewController animated:false];
}

- (void)finish {}

@synthesize charactersViewModel = _charactersViewModel;

- (CharactersViewModel *)charactersViewModel {
    @synchronized (self) {
        if (_charactersViewModel == nil) {
            MarvelServiceImpl *marvelService = [[MarvelServiceImpl alloc] initWith:self.apiClient persistentContainer:self.persistentContainer];
            _charactersViewModel = [[CharactersViewModel alloc] initWithMarvelService:marvelService imageLoader:self.imageLoader];
            _charactersViewModel.coordinatorDelegate = self;
        }
    }
    return _charactersViewModel;
}

#pragma mark - App Coordinator Delegate

- (void)goToChat:(NSString *)userId {
    ChatServiceImpl *chatService = [[ChatServiceImpl alloc] initWithSocket:self.chatSocket persistantContainer:self.persistentContainer];
    self.chatViewModel = [[ChatViewModel alloc] initWith:chatService imageLoader:self.imageLoader userId:userId];
    ChatViewController *chatController = [[ChatViewController alloc] initWith:self.chatViewModel];
    [self.rootViewController pushViewController:chatController animated:YES];
}

#pragma mark - Image Loader

@synthesize imageLoader = _imageLoader;

- (ImageloaderImpl *)imageLoader {
    @synchronized (self) {
        if (_imageLoader == nil) {
            NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:50 * 1024 * 1024
                                                              diskCapacity:100 * 1024 * 1024
                                                                  diskPath:@"TTChat.images"];
            _imageLoader = [[ImageloaderImpl alloc] initWithCahce:cache];
        }
    }
    return _imageLoader;
}

#pragma mark - Root View Controller

@synthesize rootViewController = _rootViewController;

- (UINavigationController *)rootViewController {
    @synchronized (self) {
        if (_rootViewController == nil) {
            _rootViewController = [[UINavigationController alloc] init];
        }
    }
    return _rootViewController;
}

#pragma mark - Chat Socket

@synthesize chatSocket = _chatSocket;

- (ChatSocketImpl *)chatSocket {
    @synchronized (self) {
        if (_chatSocket == nil) {
            _chatSocket = [[ChatSocketImpl alloc] init];
        }
    }
    return _chatSocket;
}

#pragma mark - Marvel Api Client

@synthesize apiClient = _apiClient;

- (MarvelApiClientImpl *)apiClient {
    @synchronized (self) {
        if (_apiClient == nil) {
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            _apiClient = [[MarvelApiClientImpl alloc] initWith: sessionConfiguration];
        }
    }
    return _apiClient;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"TTChatModel"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
            _persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            _persistentContainer.viewContext.undoManager = nil;
            _persistentContainer.viewContext.shouldDeleteInaccessibleFaults = YES;
            _persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
        }
    }
    
    return _persistentContainer;
}
@end
