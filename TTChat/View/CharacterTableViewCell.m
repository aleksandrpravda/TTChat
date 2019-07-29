//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "CharacterTableViewCell.h"
#import "CharactersViewModel.h"

@interface CharacterTableViewCell()
@property (strong, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) CharacterViewData *viewData;
@end

@implementation CharacterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self removeObserver];
    [self.thumbImageView setImage:nil];
}

- (void)removeObserver {
    [self.viewData removeObserver:self forKeyPath:@"imageData" context:@"cellContext"];
    self.viewData = nil;
}

- (void)setData:(CharacterViewData *)viewData {
    self.viewData = viewData;
    self.nameLabel.text = viewData.name;
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    [self.viewData addObserver:self
                    forKeyPath:@"imageData"
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context:@"cellContext"
     ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"imageData"]) {
        [self.activityIndicator setHidden:YES];
        [self.activityIndicator stopAnimating];
        [self.thumbImageView setImage:[UIImage imageWithData:((CharacterViewData *)object).imageData]];
    }
}
@end
