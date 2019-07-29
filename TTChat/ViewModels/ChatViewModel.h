//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatService.h"
#import "ImageLoader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatViewModelDelegate <NSObject>
- (void)pushOwnerMessage:(NSString *)text;
- (void)pushCharacterMessage:(NSString *)text;
- (void)connectionSucceeded:(NSArray *)array;
@end

@interface ChatViewModel : NSObject
@property(nonatomic, weak) id<ChatViewModelDelegate> delegate;
- (instancetype)initWith:(id<ChatService>)service imageLoader:(id<Imageloader>)imageLoader userId:(NSString *)useId;
- (NSArray *)getQuestions;
- (void)selectQuestion:(NSString *)question;
- (void)connect;
- (void)disconnect;
@end

NS_ASSUME_NONNULL_END
