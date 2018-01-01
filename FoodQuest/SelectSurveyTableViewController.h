//
//  SelectSurveyTableViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/10.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectSurveyTableViewController : UITableViewController

@property NSMutableArray *surveys;

@property BOOL respondingToURL;

@property NSString *urlSurveyID;
@property NSString *urlShortID;

// we're going to respond to an url, so set respondingToURL flag, 
// and set the surveyID and shortID for the survey to be displayed
-(void)prepareToDisplayURLSurveyID:(NSString *)surveyID andShortID:(NSString *)shortID;
-(void)displaySurveyController:(NSNotification *)notification ;
-(void)displaySurveyControllerForSurveyID:(NSString *)surveyID andShortID:(NSString *)shortID; // called in response to an url

// before going to survey view, set the selected survey and the unwindSegue to use on return
// when survey is completed, unwind to either surveyTableViewController
// or to FQMainTableVIew (if responding to an URL)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

// unwind segues we respond to
- (IBAction)unwindToSurveyTable:(UIStoryboardSegue *)unwindSegue;


@end
