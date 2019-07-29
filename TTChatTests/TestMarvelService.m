//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MarvelApiClient.h"
#import "MarvelService.h"
#import <CoreData/CoreData.h>

@interface TestMarvelService : XCTestCase
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@end

@implementation TestMarvelService
@synthesize persistentContainer = _persistentContainer;
- (void)testGetCharacters {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"wait"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    MarvelApiClientImpl *client = [[MarvelApiClientImpl alloc] initWith:configuration];
    MarvelServiceImpl* service = [[MarvelServiceImpl alloc] initWith:client persistentContainer: self.persistentContainer];
    [service loadNextCharacters:^(NSArray *array, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(array);
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:10];
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"TTChat"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
        _persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        _persistentContainer.viewContext.undoManager = nil;
        _persistentContainer.viewContext.shouldDeleteInaccessibleFaults = YES;
        
        _persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
    }
    
    return _persistentContainer;
}
@end
