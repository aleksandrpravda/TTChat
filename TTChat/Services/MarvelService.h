//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarvelApiClient.h"
@class NSPersistentContainer;

NS_ASSUME_NONNULL_BEGIN
@protocol MarvelService <NSObject>
- (BOOL)canLoadNext;
- (void)loadNextCharacters:(void (^)(NSArray * _Nullable, NSError * _Nullable))callback;
@end

@interface MarvelServiceImpl : NSObject<MarvelService>
- (instancetype)initWith:(id <MarvelApiClient>)apiClient persistentContainer:(NSPersistentContainer *)container;
@end

NS_ASSUME_NONNULL_END
