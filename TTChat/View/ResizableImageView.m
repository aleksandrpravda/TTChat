//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ResizableImageView.h"

@implementation ResizableImageView
- (void)setImage:(UIImage *)image {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(17, 21, 17, 21);
    UIImage *rImage = [image resizableImageWithCapInsets:edgeInsets];
    [super setImage:rImage];
}
@end
