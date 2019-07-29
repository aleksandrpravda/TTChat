//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController
- (instancetype)initWith:(ChatViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
