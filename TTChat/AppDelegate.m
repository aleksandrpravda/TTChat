//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "AppDelegate.h"
#import "AppCoordinator.h"
#import "ServerSideSimulator.h"

@interface AppDelegate ()
@property(strong, nonatomic) AppCoordinator *appCoordinator;
@property(strong, nonatomic) ServerSideSimulator *server;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.appCoordinator = [[AppCoordinator alloc] initWith:self.window];
    [self.appCoordinator start];
    self.server = [[ServerSideSimulator alloc] init];
    return YES;
}
@end
