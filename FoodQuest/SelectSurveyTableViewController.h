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


-(void)displaySurveyController:(NSNotification *)notification ;

- (IBAction)unwindToSurveyTable:(UIStoryboardSegue *)unwindSegue;

@end
