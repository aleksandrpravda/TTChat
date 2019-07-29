//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarvelService.h"
#import "ImageLoader.h"
#import "AppCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface CharacterViewData : NSObject
@property (strong) NSString *name;
@property (strong, nullable) NSData *imageData;
@end

@protocol CharactersViewModelDelegate <NSObject>
- (void)insertAt:(NSArray *)indexPaths;
- (void)errorWithMessage:(NSString *)message;
@end

@interface CharactersViewModel : NSObject
@property(strong) id<AppCoordinatorDelegate> coordinatorDelegate;
@property (nonatomic, weak) id<CharactersViewModelDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *viewDataArray;
- (instancetype)initWithMarvelService:(id<MarvelService>)service imageLoader:(id<Imageloader>)imageLoader;
- (void)loadThumbFor:(NSIndexPath *)indexPath;
- (BOOL)loadNext;
- (void)selectRow:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
