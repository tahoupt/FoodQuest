//
//  SurveyViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/8.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"

@interface SurveyViewController : UIViewController <ORKTaskViewControllerDelegate>

@property NSDictionary *survey;

- (NSSet *)dataTypesToWrite;
- (NSSet *)dataTypesToRead;

@end
