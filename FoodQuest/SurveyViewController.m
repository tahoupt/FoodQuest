//
//  SurveyViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/8.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "SurveyViewController.h"
#import "SurveyTaskViewController.h"
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
    SurveyTaskViewController *taskViewController = [[SurveyTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [self presentViewController:taskViewController animated:YES completion:nil];
    
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {

    
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
    
        ORKTaskResult *taskResult = [taskViewController result];

        NSMutableDictionary *resultDictionary = FQTaskResultToDictionary(taskResult,_survey);
        
        SaveResultToFirebase(resultDictionary);

    }
    
    
    
    // https://stackoverflow.com/questions/39830955/pop-to-root-view-controller-from-modal
    //    You can check that current controller is presented, 
    //    if it is presented then dismiss it and then go to the rootViewController 
    //    other wise go directly the rootViewController
    
    // google self.navigationcontroller is nil after pushviewcontroller
    // https://stackoverflow.com/questions/8845355/uiviewcontroller-navigationcontroller-becomes-nil
    // https://stackoverflow.com/questions/7767049/self-navigationcontroller-is-null
    
    // try pushViewController of menu and survey table on navigation controller?
    
    // try     [self presentModalViewController: _surveyMenuController animated:YES]; ??

    // try making properties of controllers (_navigationController etc) in App Delegate be (strong, nonatomic)
    
    // GOT TO WORK BY MAKING appdelegate window rootviewcontroller = menuNavigationController (and not introViewController), a
    // and then using [menuNavigationController pushViewController:_surveryViewController] to display survey
    
    // dismiss taskViewController
     [self dismissViewControllerAnimated:YES  completion:nil];

    [self.navigationController popToRootViewControllerAnimated:YES];

//    if (self.presentingViewController != nil) {
//        [self dismissViewControllerAnimated:YES  completion: ^ { 
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }];
//    }
//    else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }

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




@end




