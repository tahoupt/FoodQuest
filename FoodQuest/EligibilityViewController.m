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
        [self popAndDismissTaskViewController];


    }
    else if (ORKTaskViewControllerFinishReasonDiscarded == reason) {
        // cancelled, and user asked for result s to be discarded

        // TODO:
        // SaveCancelledResultToFirebase(resultDictionary);
        
        [self popAndDismissTaskViewController];

    }
    else if (ORKTaskViewControllerFinishReasonCompleted == reason || ORKTaskViewControllerFinishReasonSaved == reason ) {
    
                completedSurvey = YES;


        ORKTaskResult *taskResult = [taskViewController result];

        NSMutableDictionary *resultDictionary = FQTaskResultToDictionary(taskResult,[self survey]);
        
        NSMutableDictionary *step_results = resultDictionary[@"step_results"];
        
                // check date of birth
        
        // check gender
        
        // check pregnancy
        
        
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
         
         
         
         if (age < 18) {
         
            meetsCriteria = NO;

         }

        if (![gender isEqualToString:@"female"]) {
        
            meetsCriteria = NO;
        
        }
        
        if (![pregnant isEqualToString:@"true"]) {
        
            meetsCriteria = NO;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:meetsCriteria] forKey:kUserMeetsCriteriaKey ];
                            
    
        
    }
  


        if (completedSurvey) {
                
                if (meetsCriteria) {
                
                        _alert = [UIAlertController alertControllerWithTitle:@"You Meet Criteria!"
                                       message:@"You have met the criteria to be a subject in this study. If you want to join the study, please go the to 'Consent' form."
                                       preferredStyle:UIAlertControllerStyleAlert];
         
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) { [self popAndDismissTaskViewController];}];
                         
                        [_alert addAction:defaultAction];
                        [taskViewController presentViewController:_alert animated:YES completion:nil];

                }
                else {
                
                    _alert = [UIAlertController alertControllerWithTitle:@"Sorry, Not Eligible."
                                       message:@"Unfortunately, you do not meet the criteria to be a subject in this study. (We're looking for women older than 18 who are now pregnant or have previously been pregnant.)"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {
                         [self popAndDismissTaskViewController];
                       }];
                     
                    
                    [_alert addAction:defaultAction];
                    [taskViewController presentViewController:_alert animated:YES completion:nil];

                
                
                }
        } // completed survey
            
        
       


}

-(void)popAndDismissTaskViewController; {

        // Then, dismiss the task view controller.
        [self dismissViewControllerAnimated:NO completion: nil];
        [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
