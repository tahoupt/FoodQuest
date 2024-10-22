//
//  PreferenceViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"



@class ImagePreferenceChoiceAnswerFormat;

@interface PreferenceViewController : UIViewController <ORKTaskViewControllerDelegate>

-(UIImage*) framedImageNamed:(NSString *) imageName;
-(ImagePreferenceChoiceAnswerFormat *)imageChoiceWithImageIndex1:(NSInteger)index1 andImageIndex2:(NSInteger)index2;
-(ImagePreferenceChoiceAnswerFormat *)imageChoiceWithImageIndex1:(NSInteger)index1 andImageIndex2:(NSInteger)index2 showNoPreferenceButton:(BOOL)noPrefFlag;
@end

