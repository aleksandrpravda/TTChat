//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ChatUserTableViewCell.h"

@implementation ChatUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.transform = CGAffineTransformMakeRotation(M_PI);
}
@end
