//
//  FQMainTableViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/9/17.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectSurveyTableViewController;

@interface FQMainTableViewController : UITableViewController


@property  (nonatomic, strong) IBOutlet SelectSurveyTableViewController *surveyTableController;

@property NSString *currentSurveyID;
@property NSString *currentShortID;


-(IBAction)unwindToMainTable:(UIStoryboardSegue *)unwindSegue;

-(void)displaySurveyControllerForSurveyID:(NSString *)surveyID andShortID:(NSString *)shortID ; 

@end
