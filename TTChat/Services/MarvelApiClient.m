//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "MarvelApiClient.h"
#import "NSString+MD5.h"

@interface MarvelApiClientImpl()
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@end

@implementation MarvelApiClientImpl
- (instancetype)initWith:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.configuration = configuration;

    }
    return self;
}

- (void)getCharacters:(NSInteger)offset limit:(NSInteger)limit callback:(void(^)(NSArray * _Nullable, NSError * _Nullable))callback {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getUrlLimit:limit offset:offset]]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    __block NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            callback(nil, error);
            [task suspend];
        } else {
            NSError *error = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                callback(nil, error);
                return;
            }
            NSDictionary *data = json[@"data"];
            NSArray *results = data[@"results"];
            NSArray *array = results;
            callback(array, error);
            [task suspend];
        }
    }];
    [task resume];
}

- (NSString *)getUrlLimit:(NSInteger)limit offset:(NSInteger)offset {
    NSString *ts = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]];
    NSString *apiKey = @"503a5a406a23cf02d5ef5799895115bc";
    NSString *privateKey = @"a9eb755e3e88fee0ad095137f815c39ad67994dc";
    NSString *hash = [[NSString stringWithFormat:@"%@%@%@", ts, privateKey, apiKey] MD5];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%ld", (long)limit], @"limit",
                            [NSString stringWithFormat:@"%ld", (long)offset], @"offset",
                                @"503a5a406a23cf02d5ef5799895115bc", @"apikey",
                                ts, @"ts",
                                hash, @"hash",
                                nil
                            ];
    return [NSString stringWithFormat:@"https://gateway.marvel.com:443/v1/public/characters?%@", [self urlParams:params]];
}

- (NSString *)urlParams:(NSDictionary *)parameters {
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", [self percentEscapeString:key], [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    return [parameterArray componentsJoinedByString:@"&"];
}

- (NSString *)percentEscapeString:(NSString *)string {
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}
@end
