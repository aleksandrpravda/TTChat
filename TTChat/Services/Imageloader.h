//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Imageloader <NSObject>
- (NSData * _Nullable)getCachedImageData:(NSString *)stringURL;
- (void)loadImageWith:(NSString *)stringURL success:(void(^)(NSData *))success failure:(void(^)(NSError *))failure;
- (void)cancel;
@end

@interface ImageloaderImpl : NSObject<Imageloader>
- (instancetype)initWithCahce:(NSURLCache *)cache;
@end

NS_ASSUME_NONNULL_END
