//
//  FQMainTableViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/9/17.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "FQMainTableViewController.h"
#import "SelectSurveyTableViewController.h"

#import "AppDelegate.h" // in order to set mainTableController in appDelegate

@implementation FQMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.mainTableController = self;
    
    if (nil != appDelegate.launchURL) {
        [appDelegate respondToURL:appDelegate.launchURL];
    }
    
}
    
    
- (IBAction)unwindToMainTable:(UIStoryboardSegue *)unwindSegue
{

    NSLog(@"unwind to main table");


}


-(void)displaySurveyControllerForSurveyID:(NSString *)surveyID andShortID:(NSString *)shortID ; {

    // TODO: respond to notification here
    // get surveyID from the notification
    // get index of survey with surveyID in _surveys array
    // select the survey row in self.tableView,
    // show the survey view controller
    
    NSLog(@"MainTableView Got survey ID call");
    
  //  [_surveyTableController displaySurveyControllerForSurveyID:surveyID];
    
    // save the surveyID so we can pass it to the survey table controller in prepareForSegue
     _currentSurveyID = surveyID;
      _currentShortID = shortID;
     [self performSegueWithIdentifier:@"segueToSurveyTable" sender: self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
        NSLog(@"prepare segueToSurveyTable");

    if ([[segue identifier ] isEqualToString:@"segueToSurveyTable"]) {
        [(SelectSurveyTableViewController *)[segue destinationViewController] prepareToDisplayURLSurveyID:_currentSurveyID andShortID: _currentShortID];
    }
    
}


@end
