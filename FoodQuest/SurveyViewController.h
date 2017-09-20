//
//  SurveyViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/8.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"
#import "SurveyTaskViewController.h"

@interface SurveyViewController : UIViewController <ORKTaskViewControllerDelegate>

@property NSDictionary *survey;
@property SurveyTaskViewController *taskViewController;
@property IBOutlet UIViewController *homeViewController;

- (NSSet *)dataTypesToWrite;
- (NSSet *)dataTypesToRead;

// flag so that survey is not presented again when taskViewCOntroller is dismissed (which triggers viewDidAppear again)
@property BOOL surveyHasBeenPresented;
@end
