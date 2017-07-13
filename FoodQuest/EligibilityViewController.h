;
//
//  EligibilityViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/7/5.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"
#import "SurveyViewController.h"

@interface EligibilityViewController : SurveyViewController 

@property UIAlertController* alert;


-(void)viewDidAppear:(BOOL)animated; 

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error;
                     
/** called by alert on completion */
-(void)popAndDismissTaskViewController;

@end
