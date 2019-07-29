//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ChatOwnerTableViewCell.h"

@implementation ChatOwnerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.transform = CGAffineTransformMakeRotation(M_PI);
}
@end
