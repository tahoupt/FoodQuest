//
//  ImagePreferenceQuestionView.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/5/3.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"

// replicate the ORKImageSelectionView?

NS_ASSUME_NONNULL_BEGIN

@class ImagePreferenceQuestionView;
@class ImagePreferenceChoiceAnswerFormat;

@protocol ImagePreferenceSelectionViewDelegate <ORKQuestionStepCustomViewDelegate>

- (void)selectionViewSelectionDidChange:(ImagePreferenceQuestionView *)view;

@end


@interface ImagePreferenceQuestionView : ORKQuestionStepCustomView

- (instancetype)initWithImageChoiceAnswerFormat:(ImagePreferenceChoiceAnswerFormat *)answerFormat answer:(nullable id)answer;

//@property (nonatomic, weak, nullable) id<ORKQuestionStepCustomViewDelegate> delegate;
//
//@property (nonatomic, strong, nullable) id answer;
//
@end


NS_ASSUME_NONNULL_END

