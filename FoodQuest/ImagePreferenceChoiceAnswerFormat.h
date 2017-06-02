//
//  ImagePreferenceChoiceAnswerFormat.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/5/3.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

/*
see ORKImageSelectionView.m in ResearchKit for modifications to display 2-image preference choice
*/
@interface ImagePreferenceChoiceAnswerFormat : ORKImageChoiceAnswerFormat


@property NSInteger imageIndex1;
@property NSInteger imageIndex2;

@property BOOL allowNoPreference;
@property BOOL showSelectedAnswer;
@property BOOL showImageLabels;


-(id)initWithImageIndex1:(NSInteger)index1 imageLabel1:(NSString *)label1 andImageIndex2:(NSInteger)index2 imageLabel2:(NSString *)label2 imageType:(NSString *)extension showImageLabels:(BOOL)showLabelFlag showNoPreferenceButton:(BOOL)noPrefFlag showAnswer:(BOOL)showAnswerFlag; 



@end
