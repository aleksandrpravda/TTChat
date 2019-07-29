//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnswerGenerator : NSObject
+ (NSString *)getUnswerForQuestion:(NSString *)question;
@end

NS_ASSUME_NONNULL_END
