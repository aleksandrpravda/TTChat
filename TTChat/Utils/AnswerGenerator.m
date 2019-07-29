//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "AnswerGenerator.h"
#import "Consts.h"

@implementation AnswerGenerator
+ (NSString *)getUnswerForQuestion:(NSString *)question {
    NSArray *array = [self questionsAnswers][question];
    NSUInteger randomIndex = arc4random() % array.count;
    return array[randomIndex];
}

+ (NSDictionary *)questionsAnswers {
    return @{
                 kQuestionHowAreYou: @[NSLocalizedString(kAnswerFine, @""), NSLocalizedString(kAnswerDie, @""), NSLocalizedString(kAnswerIFeelGreat, @"")],
                 kQuestionWhereDoYouFrom: @[NSLocalizedString(kAnswerNotFromHere, @""), NSLocalizedString(kAnswerFromComics, @""), NSLocalizedString(kAnswerDoNotWantAnswer, @"")],
                 kQuestionWhatIsYourFavoritMovie: @[NSLocalizedString(kAnswerGoT, @""), NSLocalizedString(kAnswerTerminator, @""), NSLocalizedString(kAnswerDoNotLikeMovies, @"")],
                 kQuestionDoYouLikeLastAvengersMovie: @[NSLocalizedString(kAnswerDidnotLike, @""), NSLocalizedString(kAnswerDCBetter, @""), NSLocalizedString(kAnswerAwesome, @"")],
                 kQuestionWhoIsTheStrongestSuperheroInTheWorld: @[NSLocalizedString(kAnswerIAm, @""), NSLocalizedString(kAnswerHulk, @""), NSLocalizedString(kAnswerSuperman, @"")]
             };
}
@end
