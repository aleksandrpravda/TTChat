//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "Coordinator.h"

@interface Coordinator()
@property(nonatomic, strong) NSMutableArray *children;
@end

@implementation Coordinator
- (void)start {
}

- (void)finish {
}

- (void)addChild:(Coordinator *)coordinator {
    [self.children addObject:coordinator];
}

- (void)removeChild:(Coordinator *)coordinator {
    NSUInteger index = [self.children indexOfObject:coordinator];
    if (index != NSNotFound) {
        [self.children removeObjectAtIndex:index];
    } else {
        NSLog(@"Couldn't remove coordinator: %@. It's not a child coordinator.", coordinator);
    }
}

- (void)removeAllCoordinators {
    [self.children removeAllObjects];
}

@end
