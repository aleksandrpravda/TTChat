//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "Imageloader.h"

@interface ImageloaderImpl()
@property(atomic, strong) NSURLCache *cache;
@property(atomic, strong) NSURLSessionDataTask* dataTask;
@end

@implementation ImageloaderImpl

- (instancetype)initWithCahce:(NSURLCache *)cache {
    self = [super init];
    if (self) {
        self.cache = cache;
    }
    return self;
}

- (NSData * _Nullable)getCachedImageData:(NSString *)stringURL {
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSCachedURLResponse *cachedResponse = [self.cache cachedResponseForRequest:request];
    if (cachedResponse) {
        return cachedResponse.data;
    }
    return nil;
}

- (void)loadImageWith:(NSString *)stringURL success:(void(^)(NSData *))success failure:(void(^)(NSError *))failure {
    NSData *data = [self getCachedImageData:stringURL];
    if (data) {
        if (success) {
            success(data);
        }
        return;
    }
    NSURL *url = [NSURL URLWithString:stringURL];
    __block NSURLRequest *blockRequest = [NSURLRequest requestWithURL:url];
    self.dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.dataTask = nil;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
        } else {
            if (response && data) {
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                [self.cache storeCachedResponse:cachedResponse forRequest:blockRequest];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success(data);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        NSError *error = [NSError errorWithDomain:@"Response error" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Data is nil"}];
                        failure(error);
                    }
                });
            }
        }
    }];
    [self.dataTask resume];
}

- (void)cancel {
    [self.dataTask cancel];
}
@end
