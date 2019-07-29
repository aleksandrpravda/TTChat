//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MarvelApiClient <NSObject>
- (void)getCharacters:(NSInteger)offset limit:(NSInteger)limit callback:(void(^)(NSArray * _Nullable, NSError * _Nullable))callback;
@end
@interface MarvelApiClientImpl : NSObject<MarvelApiClient>
- (instancetype)initWith:(NSURLSessionConfiguration *)configuration;
@end

NS_ASSUME_NONNULL_END
