//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CharactersViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface CharactersViewController : UIViewController
- (instancetype)initWith:(CharactersViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
