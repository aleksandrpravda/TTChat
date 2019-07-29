//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InteractableLabel : UILabel
- (void)onTouchBegan:(void(^)(void))callback;
- (void)onTouchEnded:(void(^)(void))callback;
- (void)onTouchCanceled:(void(^)(void))callback;
@end

NS_ASSUME_NONNULL_END
