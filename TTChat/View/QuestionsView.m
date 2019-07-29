//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "QuestionsView.h"
#import "InteractableLabel.h"

@interface QuestionsView()
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray *questions;
@end

@implementation QuestionsView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.questions = [NSMutableArray new];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureScrollView];
}

- (void)addQuestions:(NSArray *)questions {
    [self.questions addObjectsFromArray:questions];
    [self configureViewContent:self.questions];
}

- (void)configureScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.scrollView];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [NSLayoutConstraint activateConstraints:@[leading, trailing, top, bottom]];
}

- (void)configureViewContent:(NSArray *)questions {
    InteractableLabel *lastlabel = self.scrollView.subviews.lastObject;
    for(NSUInteger i = 0; i < questions.count; ++i) {
        NSString *question = questions[i];
        InteractableLabel *questionLabel = [self questionLabel:NSLocalizedString(question, @"")];
        [questionLabel setTag:i];
        [self.scrollView addSubview:questionLabel];
        [questionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:questionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [NSLayoutConstraint activateConstraints:@[height]];
        if (lastlabel == nil && i == 0) {
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:questionLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
            [NSLayoutConstraint activateConstraints:@[leading]];
        } else {
            NSLayoutConstraint *horizontal = [NSLayoutConstraint constraintWithItem:lastlabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:questionLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-20.0];
            [NSLayoutConstraint activateConstraints:@[horizontal]];
        }
        if(i == questions.count - 1) {
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:questionLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
            [NSLayoutConstraint activateConstraints:@[trailing]];
        }
        NSLayoutConstraint *center = [NSLayoutConstraint constraintWithItem:questionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
        [NSLayoutConstraint activateConstraints:@[center]];
        lastlabel = questionLabel;
        CGSize labelSize = questionLabel.frame.size;
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width + labelSize.width, self.scrollView.frame.size.height)];
    }
}


- (InteractableLabel *)questionLabel:(NSString *)text {
    InteractableLabel *label = [[InteractableLabel alloc] init];
    label.text = text;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:20];
    label.numberOfLines = 1;
    [label sizeToFit];
    [label onTouchEnded:^{
        NSInteger index = label.tag;
        NSString *question = self.questions[index];
        if ([self.delegate respondsToSelector:@selector(didSelectQuestion:)]) {
            [self.delegate didSelectQuestion:question];
        }
    }];
    return label;
}
@end
