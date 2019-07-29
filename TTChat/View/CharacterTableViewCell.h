//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CharacterViewData;

@interface CharacterTableViewCell : UITableViewCell
- (void)setData:(CharacterViewData *)viewData;
- (void)removeObserver;
@end

NS_ASSUME_NONNULL_END
