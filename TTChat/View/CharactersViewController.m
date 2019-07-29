//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "CharactersViewController.h"
#import "CharactersViewModel.h"
#import "CharacterTableViewCell.h"

@interface CharactersViewController()<CharactersViewModelDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) CharactersViewModel *viewModel;
@end

@implementation CharactersViewController

- (instancetype)initWith:(CharactersViewModel *)viewModel {
    self = [super initWithNibName:NSStringFromClass([CharactersViewController class]) bundle:nil];
    if (self) {
        self.viewModel = viewModel;
        [self.viewModel setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CharacterTableViewCell class]) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([CharacterTableViewCell class])];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.viewModel loadNext];
}

- (void)viewDidDisappear:(BOOL)animated {
    for(UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[CharacterTableViewCell class]]) {
            [((CharacterTableViewCell *)cell) removeObserver];
        }
    }
    [super viewDidDisappear:animated];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.viewDataArray.count == 0 || indexPath.section == 1) {
        return 50;
    }
    return 100;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.viewModel.viewDataArray.count == 0 || indexPath.section == 1) {
        [self.viewModel loadNext];
        return [self activityCell];
    }
    CharacterViewData *viewData = self.viewModel.viewDataArray[indexPath.row];
    CharacterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CharacterTableViewCell class]) forIndexPath:indexPath];
    [cell setData:viewData];
    [self.viewModel loadThumbFor:indexPath];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.viewModel.viewDataArray.count == 0 || section == 1) {
        return 1;
    }
    return self.viewModel.viewDataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    if (self.viewModel.viewDataArray.count > 0) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)activityCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    cell.backgroundColor = [UIColor grayColor];
    UIActivityIndicatorView *iView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    iView.hidesWhenStopped = YES;
    iView.translatesAutoresizingMaskIntoConstraints = NO;
    [iView startAnimating];
    [cell addSubview:iView];
    NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:iView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:iView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [NSLayoutConstraint activateConstraints:@[horizontalConstraint, verticalConstraint]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel selectRow:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark View Model Delegate

- (void)insertAt:(NSArray *)indexPaths {
    if (@available(iOS 11.0, *)) {
        [self.tableView performBatchUpdates:^{
            if (self.tableView.numberOfSections == 1) {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.tableView beginUpdates];
        if (self.tableView.numberOfSections == 1) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
        [self.tableView endUpdates];
    }
}
- (void)errorWithMessage:(NSString *)message {
    //TODO add error handling
}

@end
