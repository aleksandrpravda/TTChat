//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CoordinatorProtocol <NSObject>
@required
- (void)start;
- (void)finish;
@end

@interface Coordinator : NSObject<CoordinatorProtocol>
- (void)addChild:(Coordinator *)coordinator;
- (void)removeChild:(Coordinator *)coordinator;
- (void)removeAllCoordinators;
@end

NS_ASSUME_NONNULL_END
