//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "CharactersViewModel.h"
#import "User+CoreDataClass.h"

@implementation CharacterViewData
@end

@interface CharactersViewModel()
@property(strong) id<MarvelService> service;
@property(strong) id<Imageloader> imageLoader;
@property(strong) NSMutableArray *users;
@end

@implementation CharactersViewModel
- (instancetype)initWithMarvelService:(id<MarvelService>)service imageLoader:(id<Imageloader>)imageLoader {
    self = [super init];
    if (self) {
        self.service = service;
        self.imageLoader = imageLoader;
        self.users = [NSMutableArray new];
        self.viewDataArray = [NSMutableArray new];
    }
    return self;
}

- (void)loadThumbFor:(NSIndexPath *)indexPath {
    User *user = [self.users objectAtIndex:indexPath.row];
    [self.imageLoader loadImageWith:user.thumbURL success:^(NSData *data) {
        CharacterViewData *viewData = [self.viewDataArray objectAtIndex:indexPath.row];
        viewData.imageData = data;
    } failure:^(NSError *error) {
        CharacterViewData *viewData = [self.viewDataArray objectAtIndex:indexPath.row];
        viewData.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"thumbnail"]);
        if ([self.delegate respondsToSelector:@selector(errorWithMessage:)]) {
            [self.delegate errorWithMessage:error.userInfo.description];
        }
    }];
}

- (BOOL)loadNext {
    [self.service loadNextCharacters:^(NSArray *array, NSError *error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(errorWithMessage:)]) {
                [self.delegate errorWithMessage:error.userInfo.description];
            }
        } else {
            NSMutableArray *indexPaths = [NSMutableArray new];
            NSInteger count = self.viewDataArray.count > 0 ? self.viewDataArray.count : 1;
            for (NSUInteger i = 0; i < array.count; ++i) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:count - 1 + i inSection:0]];
            }
            for (User *user in array) {
                [self.viewDataArray addObject:[self fromUser:user]];
            }
            [self.users addObjectsFromArray:array];
            if ([self.delegate respondsToSelector:@selector(insertAt:)]) {
                [self.delegate insertAt:indexPaths];
            }
        }
    }];
    return [self.service canLoadNext];
}

- (void)selectRow:(NSIndexPath *)indexPath {
    User *user = [self.users objectAtIndex:indexPath.row];
    [self.coordinatorDelegate goToChat:user.identifire];
}

- (CharacterViewData *)fromUser:(User *)user {
    CharacterViewData *viewData = [[CharacterViewData alloc] init];
    viewData.name = user.name;
    viewData.imageData = [self.imageLoader getCachedImageData:user.thumbURL];
    return viewData;
}
@end
