//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResizableImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatOwnerTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet ResizableImageView *bubbleImageView;

@end

NS_ASSUME_NONNULL_END
