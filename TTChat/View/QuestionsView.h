//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QuestionsViewDelegate <NSObject>

- (void)didSelectQuestion:(NSString *)question;

@end

@interface QuestionsView : UIView
@property(nonatomic, weak) id<QuestionsViewDelegate> delegate;
- (void)addQuestions:(NSArray *)questions;
@end

NS_ASSUME_NONNULL_END
