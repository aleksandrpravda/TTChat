//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MarvelApiClient.h"

@interface TestMarvelApiService : XCTestCase

@end

@implementation TestMarvelApiService

- (void)testGetCharacters {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"wait"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    MarvelApiClientImpl *client = [[MarvelApiClientImpl alloc] initWith:configuration];
    [client getCharacters:0 limit:30 callback:^(NSArray *array, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(array);
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:10];
}

@end
