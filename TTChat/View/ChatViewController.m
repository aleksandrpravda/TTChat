//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatViewModel.h"
#import "QuestionsView.h"
#import "ChatUserTableViewCell.h"
#import "ChatOwnerTableViewCell.h"

@interface ChatViewController()<ChatViewModelDelegate, QuestionsViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet QuestionsView *questionView;
@property (strong) ChatViewModel *viewModel;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation ChatViewController

- (instancetype)initWith:(ChatViewModel *)viewModel {
    self = [super initWithNibName:NSStringFromClass([ChatViewController class]) bundle:nil];
    if (self) {
        self.viewModel = viewModel;
        [self.viewModel setDelegate:self];
        self.dataArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.questionView.delegate = self;
    [self.questionView setHidden:YES];
    [self.questionView addQuestions:[self.viewModel getQuestions]];
    self.tableView.transform = CGAffineTransformMakeRotation(M_PI);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ChatOwnerTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatOwnerTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ChatUserTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ChatUserTableViewCell class])];
    [self.indicatorView setHidden:NO];
    [self.indicatorView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel connect];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.viewModel disconnect];
    [super viewDidDisappear:animated];
}

#pragma mark - Question View Delegate

- (void)didSelectQuestion:(NSString *)question {
    [self.viewModel selectQuestion:question];
}

#pragma mark - Chat ViewModel Delegate

- (void)pushOwnerMessage:(NSString *)text {
    [self.dataArray insertObject:@{@"text": text, @"owner": @(YES)} atIndex:0];
    [self.tableView reloadData];
}

- (void)pushCharacterMessage:(NSString *)text {
    [self.dataArray insertObject:@{@"text": text, @"owner": @(NO)} atIndex:0];
    [self.tableView reloadData];
}

- (void)connectionSucceeded:(NSArray *)array {
    [self.indicatorView stopAnimating];
    [self.questionView setHidden:NO];
    [self.dataArray addObjectsFromArray:array];
    [self.tableView reloadData];
}

#pragma mark - TAble View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *data = self.dataArray[indexPath.row];
    NSString *text = data[@"text"];
    BOOL isOwner = [data[@"owner"] boolValue];
    if (isOwner) {
        ChatOwnerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatOwnerTableViewCell class])];
        [cell.bubbleImageView setImage:[UIImage imageNamed:@"bubble_sent"]];
        [cell.label setText:text];
        return cell;
    } else {
        ChatUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatUserTableViewCell class])];
        [cell.bubbleImageView setImage:[UIImage imageNamed:@"bubble_received"]];
        [cell.label setText:text];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


@end
