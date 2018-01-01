//
//  SurveyViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/8.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "SurveyViewController.h"

#import "ImagePreferenceChoiceAnswerFormat.h"
#import "ImageHedonicScaleAnswerFormat.h"

#import "Firebase.h"
#import "FQUtilities.h"
#import "FQConstants.h"
#import "FQSurvey.h"
#import "FQSurveyParser.h"

#import <YAML/YAMLSerialization.h>


@interface SurveyViewController ()

@end

@implementation SurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

    // if survey has already been presented, then don't present it again 
    // (when taskViewController is dismissed, it triggers viewDidAppear again, which would present another taskViewController, and repeat...)
    if (_surveyHasBeenPresented) {
        return;
    }
    FQSurveyParser *parser = [[FQSurveyParser alloc] initWithSurvey:_survey];


    if ([HKHealthStore isHealthDataAvailable]) {

        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            else {
                NSLog(@"Healthkit access allowed.");
                return;
            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // Update the user interface based on the current user's health information.
//                
//            });
        }];
    }
/*
HKCharacteristicTypeIdentifierDateOfBirth
HKCharacteristicTypeIdentifierBiologicalSex

*/


// assume that self.survey has been set by calling view


    NSMutableArray *steps = [NSMutableArray array];

    ORKInstructionStep *instructionStep =
      [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
      
    instructionStep.title = [_survey objectForKey:@"title"];
    instructionStep.text = [_survey objectForKey:@"instructions"];
    
    NSUInteger numberOfImages = 0;
    NSDictionary *images =  [_survey objectForKey:@"images" ];
    
    if  ( nil != images && nil != [images objectForKey:@"descriptions"]) {
        numberOfImages = [[images mutableArrayValueForKey:@"descriptions"]  count];
    }
    
    [steps addObject:instructionStep];

    NSInteger section_index = 0;
    
    for (NSDictionary *section in [_survey objectForKey:@"sections"]) {
    
        if ((nil != [section objectForKey:@"instructions"] && 0 < [[section objectForKey:@"instructions"] length]) || (nil != [section objectForKey:@"title"] && 0 < [[section objectForKey:@"title"] length]) ) {
        
            NSString *sectionIndentifier = [NSString stringWithFormat:@"sectionInstruction%ld",(long)section_index];
        
            ORKInstructionStep *sectionInstructionStep =
            [[ORKInstructionStep alloc] initWithIdentifier:sectionIndentifier];
              
            sectionInstructionStep.title = [section objectForKey:@"title"];
            sectionInstructionStep.text = [section objectForKey:@"instructions"];
            [steps addObject:sectionInstructionStep];
      
        }
    
    
        for (NSDictionary *question in [section objectForKey:@"questions"]) {
            NSArray *questionSteps = [parser stepsForSurveyQuestion:question];
            if (0 < [questionSteps count]) {
                 [steps addObjectsFromArray:questionSteps];
            }
        } // questions
    
        section_index++; // next section
        
    } // sections
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:[_survey objectForKey:@"identifier" ] steps:steps];

    // start task with our subclass of ORKTaskViewController, so that it can act as StepViewControllerDelegate
    _taskViewController = [[SurveyTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    _taskViewController.delegate = self;
    [self presentViewController:_taskViewController animated:YES completion:nil];
    _surveyHasBeenPresented = YES;
    
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {
    
    BOOL completedTask = NO;
    ORKTaskResult *taskResult;
    NSMutableDictionary *resultDictionary;
    
    if (ORKTaskViewControllerFinishReasonFailed == reason) {
        // error detected
    
        // TODO:
        // SaveErrorResultToFirebase(resultDictionary);
        completedTask = NO;
    }
    else if (ORKTaskViewControllerFinishReasonDiscarded == reason) {
        // cancelled, and user asked for results to be discarded

        // TODO:
        // SaveCancelledResultToFirebase(resultDictionary);
        // or would saving canceled results be unethical?

        completedTask = NO;
    }
    else if (ORKTaskViewControllerFinishReasonCompleted == reason || ORKTaskViewControllerFinishReasonSaved == reason ) {
    
        completedTask = YES;
        ORKTaskResult *taskResult = [taskViewController result];
        resultDictionary = FQTaskResultToDictionary(taskResult,_survey);

    }
    
    [self dismissViewControllerAnimated:NO completion: ^{

        if (!completedTask) {
             [self pop];
        }
        else {
        
            NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey];
        
            if (nil == userID) { 
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Survey Results Saved"
                                           message:@"Thank you for completing this survey. Because you have not joined the study, your results have not been saved."
                                           preferredStyle:UIAlertControllerStyleAlert];
             
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                             [self pop];
                           }];
                         
                        
                [alert addAction:defaultAction];

                [self presentViewController:alert animated:YES completion:nil];        
            }
            else {
                                
                // get device info so you can verify who's connected
                resultDictionary[@"uuid"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
     
                NSMutableDictionary *healthkitDictionary = [self getHealthKitData];
                
                if (nil != healthkitDictionary) {
                    resultDictionary[@"healthkit"] = healthkitDictionary;
                }
                if (nil != _shortID) {
                
                    //responding to sms with a shortID, so save the push survey shortID and timestamp in userdefault
                    // so we don't take the same push survey twice.
                    resultDictionary[@"shortID"] = _shortID;
                    
                    NSMutableArray *priorSurveys = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPriorSurveysKey];
                    if (nil == priorSurveys) { priorSurveys = [NSMutableArray array]; }
                    NSArray *this_survey = @[resultDictionary[@"survey_key"],resultDictionary[@"shortID"],resultDictionary[@"start_time"]];
                    [priorSurveys addObject:this_survey];
                    [[NSUserDefaults standardUserDefaults] setObject:priorSurveys forKey:kUserPriorSurveysKey];
            
                }
                
                SaveResultToFirebase(resultDictionary);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Survey Results Saved"
                                           message:@"Thank you for completing this survey. Your results have been saved to the study database."
                                           preferredStyle:UIAlertControllerStyleAlert];
             
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                             [self pop];
                           }];
                         
                        
                [alert addAction:defaultAction];

                [self presentViewController:alert animated:YES completion:nil];

            }
        
        }

    }]; // dismiss taskviewcontroller
    
    
    
}

-(void)pop; {
   // GOT TO WORK BY MAKING appdelegate window rootviewcontroller = menuNavigationController (and not introViewController), a
    // and then using [menuNavigationController pushViewController:_surveryViewController] to display survey
    
    // _unwindSegueID is set by call segue, 
    // e.g. to be @"unwindToSurveyTable" or @"unwindToMainTable"
    [self performSegueWithIdentifier:_unwindSegueID sender: self];

//// dismiss taskViewController and pop up
//    if (nil != [self presentedViewController]) {
//        [self dismissViewControllerAnimated:YES  completion:^{
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }];
//    }
//    else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSLog(@"prepare for segue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"unwindToSurveyTable"]) {
    
        NSLog(@"Prepare for unwindToSurveyTable");
    }
    if ([segue.identifier isEqualToString:@"unwindToMainTable"]) {
    
        NSLog(@"Prepare for unwindToMainTable");
    }
}


// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {

    return [NSSet set];

/*

    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, nil];
*/

}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *basalEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];

    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:stepCountType, dietaryCalorieEnergyType,basalEnergyBurnType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType, nil];
}


-( NSMutableDictionary *)getHealthKitData; {


    if (nil == _survey[@"healthkit"]) {  return nil; }
    

    __block NSMutableDictionary *hkResults = [NSMutableDictionary dictionary];
    __block NSMutableArray *errors = [NSMutableArray array];

    dispatch_group_t serviceGroup = dispatch_group_create();

    NSArray *healthKitSamples = _survey[@"healthkit"];
    for (NSDictionary *sample in healthKitSamples) {
        dispatch_group_enter(serviceGroup);
        [self fetchHKQuantityWithIdentifier:sample[@"data_type"] andKey:sample[@"key"] forInterval:[sample[@"interval"] doubleValue] completion:^(NSString *key,NSString *data_type, double results, NSError* error){

            hkResults[key] = @{ @"data":[NSNumber numberWithDouble:results],@"type":data_type};
            if (nil != error) { [errors addObject:error]; }
            else { [errors addObject:[NSNull null]]; }
            dispatch_group_leave(serviceGroup);
        }];
    }
        
    dispatch_group_wait(serviceGroup,DISPATCH_TIME_FOREVER);
    // Won't get here until everything has finished    

    for (NSDictionary *sample in healthKitSamples) {
        NSLog(@"%@: %lf",sample[@"key"],[hkResults[sample[@"key"]][@"data"] doubleValue]);
    }
    
    return hkResults;
    
}


- (void)fetchHKQuantityWithIdentifier:(NSString *)identifier andKey:(NSString *)key forInterval:(double)interval completion:(void (^)(NSString *,NSString *,double,NSError *))completionHandler; {

// You need only a single HealthKit store per app. These are long-lived objects. Create the store once, and keep a reference for later use.
    if (![HKHealthStore isHealthDataAvailable]) {
        return;
    }
    
    self.healthStore = [[HKHealthStore alloc] init];

    // just add @"HKQuantityTypeIdentifier" to beginning of capitalized identifier
    NSString *capitalizedIentifier = [[[identifier substringToIndex:1] uppercaseString] stringByAppendingString:[identifier substringFromIndex:1]];
    HKQuantityTypeIdentifier hkIdentifier = [@"HKQuantityTypeIdentifier" stringByAppendingString:capitalizedIentifier];

    NSLog(@"hkid: %@", hkIdentifier);
    

    NSCalendar *calendar = [NSCalendar currentCalendar];
     
    NSDate *endDate = [NSDate date];
      
    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitSecond value: (-1 * interval)toDate:endDate options:0];
    
    NSLog(@"start: %lf end: %lf", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]);
     
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:hkIdentifier];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
 
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:sampleType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (!result) {
            if (completionHandler) {
                completionHandler(key, identifier,NAN, error);
            }
            return;
        }
 
        double totalSteps = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
        if (completionHandler) {
            completionHandler(key,identifier,totalSteps, error);
        }
    }];
 
    [self.healthStore executeQuery:query];


}


@end




