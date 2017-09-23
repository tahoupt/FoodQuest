//
//  EligibilityViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/7/5.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "EligibilityViewController.h"
#import "Firebase.h"
#import "FQUtilities.h"
#import "FQConstants.h"
#import "FQSurvey.h"
#import "FQSurveyParser.h"

#import <YAML/YAMLSerialization.h>

@interface EligibilityViewController ()

@end

@implementation EligibilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //  if already joined then put up alert so we can't join again
    [self alreadyJoined];
    
    NSError * error;

    NSString * surveysPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"surveys"];
    
    NSString* path = [surveysPath stringByAppendingPathComponent:@"eligibility.yaml"];
    
    NSString *yamlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

    NSMutableArray *yamlObjects = [YAMLSerialization
                                        objectsWithYAMLString: yamlString
                                        options:  kYAMLReadOptionStringScalars
                                        error: &error];
                                        
                                                    
    [self setSurvey : [yamlObjects firstObject] ] ;                                               


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewDidAppear:(BOOL)animated; {

    [super viewDidAppear:animated];
 
    NSLog(@"EligibilityViewController did appear");
}



-(BOOL)alreadyJoined; {


    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultUserIDKey];
    
    if (nil != user_id) {
    
        // TODO: put up alert that we've already joined
                      _alert = [UIAlertController alertControllerWithTitle:@"Already Participating."
                                       message:@"You've already joined the study, so you don't need to join again. Thanks again for your participation!"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {
                         [self pop];
                       }];
                     
                    
                    [_alert addAction:defaultAction];

                    [self presentViewController:_alert animated:YES completion:nil];
    
        return YES;
    }
    
    return NO;
}
- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {
                     
    BOOL completedSurvey = NO;
    BOOL meetsCriteria = YES;

    if (ORKTaskViewControllerFinishReasonFailed == reason) {
        // error detected
    
        // TODO:
        // SaveErrorResultToFirebase(resultDictionary);
    

    }
    else if (ORKTaskViewControllerFinishReasonDiscarded == reason) {
        // cancelled, and user asked for result s to be discarded

        // TODO:
        // SaveCancelledResultToFirebase(resultDictionary);
        
    }
    else if (ORKTaskViewControllerFinishReasonCompleted == reason || ORKTaskViewControllerFinishReasonSaved == reason ) {
    
        completedSurvey = YES;

        ORKTaskResult *taskResult = [taskViewController result];

        NSMutableDictionary *resultDictionary = FQTaskResultToDictionary(taskResult,[self survey]);
        
        NSMutableDictionary *step_results = resultDictionary[@"step_results"];
        
        // check date of birth, gender, pregnancy
        
        
        NSDictionary *b = step_results[@"birth_date"] ;
        NSString *bstring = b[@"answer"];
        NSTimeInterval birthdate = [bstring doubleValue];
        // Get the system calendar
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];

        // Create the NSDates
        NSDate *date1 = [[NSDate alloc] init];
        NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSince1970:birthdate];

        unsigned int unitFlags = NSCalendarUnitYear;

        NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date2  toDate:date1  options:0];

        NSInteger age = [conversionInfo year];
        
        NSDictionary *g = step_results[@"gender"];
        NSString *gender = g[@"answer"];

        NSDictionary *p = step_results[@"pregnancy"];
        NSString *pregnant = p[@"answer"];
         
        if (age < 18) {  meetsCriteria = NO; }
        if (![gender isEqualToString:@"female"]) {  meetsCriteria = NO; }
        if (![pregnant isEqualToString:@"true"]) { meetsCriteria = NO; }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:meetsCriteria] forKey:kUserMeetsCriteriaKey ];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:birthdate] forKey:kUserDateOfBirthKey ];
        [[NSUserDefaults standardUserDefaults] setObject:gender forKey:kUserSexKey ];

        
    }
  
    // get rid of taskcontroller, then either return to maintable or put up alerts:
    // either did not meet criteria, then return to maintable
    // or eligible, so join or cancel (return to maintable)
    
    [self dismissViewControllerAnimated:NO completion: ^{

            if (!completedSurvey) {
                 [self pop];
            }
            else  {
                    
                if (meetsCriteria) {
                
                        _alert = [UIAlertController alertControllerWithTitle:@"You Meet the Criteria!"
                                       message:@"You have met the criteria to be a subject in this study. If you want to join the study, please continue to the 'Consent' form."
                                       preferredStyle:UIAlertControllerStyleAlert];
         
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Join Study" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) { [self continueToSettingsController];}];
                         
                        [_alert addAction:defaultAction];
                        
                        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) { [self pop];}];
                        [_alert addAction:cancelAction];


                        [self presentViewController:_alert animated:YES completion:nil];

                }
                else {
                
                    _alert = [UIAlertController alertControllerWithTitle:@"Sorry, Not Eligible."
                                       message:@"Unfortunately, you do not meet the criteria to be a subject in this study. (We're looking for women older than 18 who are now pregnant or have previously been pregnant.)"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {
                         [self pop];
                       }];
                     
                    
                    [_alert addAction:defaultAction];

                    [self presentViewController:_alert animated:YES completion:nil];

                
                }
            } // completed survey
            
       }]; // dismiss task controller


}

-(void)pop; {

    [self performSegueWithIdentifier:@"unwindToMainTable" sender: self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSLog(@"prepare for segue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"unwindToMainTable"]) {
    
        NSLog(@"Prepare for unwindToMainTable");
    }
}

-(void)continueToSettingsController; {

    UIViewController *settingsViewController = [self.storyboard 
        instantiateViewControllerWithIdentifier:@"SettingsViewController"];
 
    [self presentViewController:settingsViewController animated:YES completion:NULL];
                                                     
}

@end
