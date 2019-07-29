//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "Coordinator.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

@protocol AppCoordinatorDelegate <NSObject>
- (void)goToChat:(NSString *)chatId;
@end

@interface AppCoordinator : Coordinator
- (instancetype)initWith:(UIWindow *)window;
@end

NS_ASSUME_NONNULL_END
