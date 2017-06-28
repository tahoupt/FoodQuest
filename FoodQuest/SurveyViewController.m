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
    
        NSString *sectionIndentifier = [NSString stringWithFormat:@"sectionInstruction%ld",(long)section_index];
    
        ORKInstructionStep *sectionInstructionStep =
        [[ORKInstructionStep alloc] initWithIdentifier:sectionIndentifier];
          
        sectionInstructionStep.title = [section objectForKey:@"title"];
        sectionInstructionStep.text = [section objectForKey:@"instructions"];
        [steps addObject:sectionInstructionStep];
  
    
    
        for (NSDictionary *question in [section objectForKey:@"questions"]) {
        
            ORKAnswerFormat *answerFormat = [parser parseSurveyQuestion:question];
            
            
 /*           
 
 BOOL healthkitPermission = NO;

    NSLocale *locale = [NSLocale currentLocale]; 
    BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];

    NSString *weightUnits = isMetric ? @"kg" : @"lbs";
    NSString *lengthUnits = isMetric ? @"cm" : @"inches";
    
    
            if ([question objectForKey:@"key"] == nil ) {
                NSLog(@"bad key");
                answerFormat = nil;

            }
            else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyMultipleChoiceType]) {
                NSMutableArray *answerChoices = [NSMutableArray array];
                for (NSDictionary *answer in [question objectForKey:@"answers"]) {
                    ORKTextChoice * choice = [ORKTextChoice choiceWithText:[answer objectForKey:@"text"] detailText:NULL value:[answer objectForKey:@"value"] exclusive:YES];
                    [answerChoices addObject:choice];
                }
                            
                answerFormat = [[ORKTextChoiceAnswerFormat alloc] 
                                                                initWithStyle: ORKChoiceAnswerStyleMultipleChoice
                                                                textChoices: answerChoices];
            }
            else if ([[question objectForKey:@"type"]  isEqualToString:kFQSurveyDateOfBirthType]) {
                if (healthkitPermission) {
                    answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType: [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]];
                }
                else {
                    answerFormat = [ORKAnswerFormat dateTimeAnswerFormat];
                }
            }
            else if ([[question objectForKey:@"type"]  isEqualToString:kFQSurveyGenderType]) {
                if (healthkitPermission) {
                    answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType: [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
                }
                else {
                    NSMutableArray *sexChoices = [NSMutableArray array];
                    ORKTextChoice * choice = [ORKTextChoice choiceWithText:@"female" detailText:NULL value:@"female" exclusive:YES];
                    [sexChoices addObject:choice];
                    choice = [ORKTextChoice choiceWithText:@"male" detailText:NULL value:@"male" exclusive:YES];
                    [sexChoices addObject:choice];

                    answerFormat = [[ORKTextChoiceAnswerFormat alloc] 
                                    initWithStyle: ORKChoiceAnswerStyleMultipleChoice
                                    textChoices: sexChoices];
                }
            }
           else if ([[question objectForKey:@"type"]  isEqualToString:kFQSurveyIntegerType]) {
                    answerFormat = [[ORKNumericAnswerFormat alloc]initWithStyle:ORKNumericAnswerStyleInteger];
            } 
            else if ([[question objectForKey:@"type"]  isEqualToString:kFQSurveyDecimalType]) {
                    answerFormat = [[ORKNumericAnswerFormat alloc]initWithStyle:ORKNumericAnswerStyleDecimal];
            }            
            else if ([[question objectForKey:@"type"]  isEqualToString:kFQSurveyHeightType]) {
                    answerFormat = [ORKAnswerFormat heightAnswerFormat];
            }            
            else if ([[question objectForKey:@"type"]  isEqualToString:kFQSurveyWeightType]) {
                answerFormat = [ORKAnswerFormat integerAnswerFormatWithUnit:weightUnits];
            }            
            else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyBooleanType]) {
                answerFormat = [ORKAnswerFormat booleanAnswerFormat];
            }
            else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyImagePairType]) {
            
                    NSDictionary *answer = [[question objectForKey:@"answers" ] firstObject ];
                    NSInteger image1Index =  [[answer objectForKey:@"image_index"] integerValue];
                    NSString *image1Label =  [answer objectForKey:@"image_label"];
                    
                    NSDictionary *answer2 = [[question objectForKey:@"answers" ] objectAtIndex:1];
                    NSInteger image2Index =  [[answer2 objectForKey:@"image_index"] integerValue];
                    NSString *image2Label =  [answer2 objectForKey:@"image_label"];

                    BOOL show_image_labels = NO;
                    BOOL allow_no_preference = NO;
                    BOOL show_answer = NO;
                    if ([answer objectForKey:@"show_image_labels"]) {
                        show_image_labels = [[answer objectForKey:@"show_image_labels"] boolValue];
                    }
                   if ([answer objectForKey:@"allow_no_preference"]) {
                        allow_no_preference = [[answer objectForKey:@"allow_no_preference"] boolValue];
                    }
                   if ([answer objectForKey:@"show_answer"]) {
                        show_answer = [[answer objectForKey:@"show_answer"] boolValue];
                    }
                    
                answerFormat = [[ImagePreferenceChoiceAnswerFormat alloc] 
                        initWithImageIndex1: image1Index
                        imageLabel1:image1Label
                        andImageIndex2: image2Index
                        imageLabel2:image2Label
                        imageType: [images objectForKey:@"extension" ] 
                        showImageLabels: show_image_labels
                        showNoPreferenceButton:allow_no_preference 
                        showAnswer:show_answer]; 
            }

            else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyRandomImagePairsType]) {
            
                answerFormat = nil; // we'll add random questions below...
              
            }
            else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyHedonicScaleType]) {
                    
                    NSDictionary *answer = [[question objectForKey:@"answers" ] firstObject ];
                    NSInteger imageIndex =  [[answer objectForKey:@"image_index"] integerValue];
                    NSString *imageLabel =  [answer objectForKey:@"image_label"] ;
                    BOOL show_image_labels = NO;
                    BOOL allow_no_preference = NO;
                    BOOL show_answer = NO;
                    if ([answer objectForKey:@"show_image_labels"]) {
                        show_image_labels = [[answer objectForKey:@"show_image_labels"] boolValue];
                    }
                   if ([answer objectForKey:@"allow_no_preference"]) {
                        allow_no_preference = [[answer objectForKey:@"allow_no_preference"] boolValue];
                    }
                   if ([answer objectForKey:@"show_answer"]) {
                        show_answer = [[answer objectForKey:@"show_answer"] boolValue];
                    }

                    
                    if ([[answer objectForKey:@"scale_type"] isEqualToString:kFQLabeledMagnitudeSurveyScaleType]) {
                        answerFormat =  [[LHSImageScaleAnswerFormat alloc] 
                            initWithImageIndex:imageIndex 
                            imageType: [images objectForKey:@"extension" ]  
                            imageLabel:imageLabel
                            showImageLabel: show_image_labels];
                    }
                    else  if ([[question objectForKey:@"scale_type"] isEqualToString:kFQNatickSurveyScaleType]) {
                        answerFormat =  [[NatickImageScaleAnswerFormat alloc] 
                            initWithImageIndex:imageIndex 
                            imageType: [images objectForKey:@"extension" ]  
                            imageLabel:imageLabel
                            showImageLabel: show_image_labels];
                    }

            }
            else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyRandomHedonicScaleType]) {
                answerFormat = nil;
            }
            else  {
                // can't identify answer type, so skip this step
                NSLog(@"unknown answer type");
                answerFormat = nil;
            }

*/


            if (answerFormat == nil ) {
                // eiher unknown question type, or its a random question type that might need repeating
            
                if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyRandomImagePairsType]) {
                    // variable number of random pair comparisons
                    
                    NSInteger numQuestions;
                    if (nil ==  [question objectForKey:@"repeat"]) {
                        numQuestions = 1;
                    }
                    else {
                        numQuestions = [[question objectForKey:@"repeat"] integerValue];
                    }                    NSUInteger numFoodPictures = [[images objectForKey:@"descriptions"] count];
                    
                    for (NSInteger i = 0; i< numQuestions; i++) {
                    
                        // NOTE: make sure index not aleady used
                        // NOTE: add image labels from descriptions
                        //  NSString *imageLabel = [[images mutableArrayValueForKey:@"descriptions"] objectAtIndex:imageIndex];
                        
                        // imageIndexes for file names are 1-indexed, but descriptions are 0-indexed
                            NSInteger image1Index = arc4random_uniform((unsigned int)numFoodPictures) + 1;
                            NSInteger image2Index = arc4random_uniform((unsigned int)numFoodPictures) + 1;
                                
                            // make sure they are non-identical indexes
                            while (image1Index == image2Index) {
                                image2Index = arc4random_uniform((unsigned int)numFoodPictures) + 1;
                            }
                            // make sure the comparison has not been previously used?
    
                    NSString *image1Label = [[images mutableArrayValueForKey:@"descriptions"] objectAtIndex:image1Index-1];
                    NSString *image2Label = [[images mutableArrayValueForKey:@"descriptions"] objectAtIndex:image2Index-1];
                    BOOL show_image_labels = NO;
                    BOOL allow_no_preference = NO;
                    BOOL show_answer = NO;
                    NSDictionary *answer = [[question objectForKey:@"answers"] firstObject];
                    if ([answer objectForKey:@"show_image_labels"]) {
                        show_image_labels = [[answer objectForKey:@"show_image_labels"] boolValue];
                    }
                   if ([answer objectForKey:@"allow_no_preference"]) {
                        allow_no_preference = [[answer objectForKey:@"allow_no_preference"] boolValue];
                    }
                   if ([answer objectForKey:@"show_answer"]) {
                        show_answer = [[answer objectForKey:@"show_answer"] boolValue];
                    }
                    
                     answerFormat = [[ImagePreferenceChoiceAnswerFormat alloc] 
                                initWithImageIndex1: image1Index
                                imageLabel1:image1Label
                                andImageIndex2: image2Index
                                imageLabel2:image2Label
                                imageType: [images objectForKey:@"extension" ] 
                                showImageLabels: show_image_labels
                                showNoPreferenceButton:allow_no_preference
                                showAnswer:show_answer]; 
                                
                        NSString *identifier = [NSString stringWithFormat:@"%@%ld", [question objectForKey:@"key"], i];
                        ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:identifier  
                                title:[question objectForKey:@"stem"]   answer:answerFormat];
                                [steps addObject:questionStep];

                    } // next random ImagePreferenceChoiceAnswerFormat                            
                } // kFQSurveyRandomImagePairsType
                 else if ([[question objectForKey:@"type"] isEqualToString:kFQSurveyRandomHedonicScaleType]) {
                 
                    NSDictionary *answer = [[question objectForKey:@"answers" ] firstObject ];
                    NSString *scale_type =  [answer objectForKey:@"scale_type"] ;
                    BOOL show_image_labels = NO;
                    BOOL allow_no_preference = NO;
                    BOOL show_answer = NO;
                    if ([answer objectForKey:@"show_image_labels"]) {
                        show_image_labels = [[answer objectForKey:@"show_image_labels"] boolValue];
                    }
                   if ([answer objectForKey:@"allow_no_preference"]) {
                        allow_no_preference = [[answer objectForKey:@"allow_no_preference"] boolValue];
                    }
                   if ([answer objectForKey:@"show_answer"]) {
                        show_answer = [[answer objectForKey:@"show_answer"] boolValue];
                    }
                    
                    
                    NSInteger numQuestions;
                    if (nil ==  [question objectForKey:@"repeat"]) {
                        numQuestions = 1;
                    }
                    else {
                        numQuestions = [[question objectForKey:@"repeat"] integerValue];
                    }
                    for (NSInteger i = 0; i< numQuestions; i++) {

                        // imageIndexes for file names are 1-indexed, but descriptions are 0-indexed

                        NSInteger imageIndex = arc4random_uniform((unsigned int)numberOfImages) + 1;
                        NSString *imageLabel = [[images mutableArrayValueForKey:@"descriptions"] objectAtIndex:imageIndex-1];
                        
                        // NOTE: make sure index not aleady used
//                        while (AlreadyInArray(imageIndex,usedRandomScaleIndexes)) {
//                        
//                            imageIndex = arc4random_uniform(numberOfImages) + 1;
//                        }
//                        [usedRandomScaleIndexes addObject:[NSNumber numberWithInteger:imageIndex]];
                        
                        
                        if ([scale_type isEqualToString:kFQLabeledMagnitudeSurveyScaleType]) {
                            answerFormat =  [[LHSImageScaleAnswerFormat alloc] 
                                initWithImageIndex:imageIndex 
                                imageType: [images objectForKey:@"extension" ]  
                                imageLabel:imageLabel
                                showImageLabel:show_image_labels];
                        }
                        else  if ([scale_type isEqualToString:kFQNatickSurveyScaleType]) {
                        
                        
                            answerFormat =  [[NatickImageScaleAnswerFormat alloc] 
                                initWithImageIndex:imageIndex 
                                imageType: [images objectForKey:@"extension" ]  
                                imageLabel:imageLabel
                                showImageLabel:show_image_labels];
                                
                                            
                        }
                        
                        NSString *identifier = [NSString stringWithFormat:@"%@%ld", [question objectForKey:@"key"], i];
                        
                        ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:identifier  
                                    title:[question objectForKey:@"stem"]   answer:answerFormat];
                                    [steps addObject:questionStep];
                    } // next random image hedonic scaling format
                } // kFQSurveyRandomHedonicScaleType
            } // nil answer format
            else {
                // answer format for single question step
                ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:[question objectForKey:@"key"]  
                title:[question objectForKey:@"stem"]   answer:answerFormat];
                
                [steps addObject:questionStep];
            
            } // single question

        } // questions
    
        section_index++; // next section
    } // sections
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:[_survey objectForKey:@"identifier" ] steps:steps];

    // start task with our subclass of ORKTaskViewController, so that it can act as StepViewControllerDelegate
    SurveyTaskViewController *taskViewController =
      [[SurveyTaskViewController alloc] initWithTask:task taskRunUUID:nil];
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

        NSMutableDictionary *resultDictionary = FQTaskResultToDictionary(taskResult);
        
        SaveResultToFirebase(resultDictionary);

    }
    
    

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // go back to main table view
    [self.navigationController popToRootViewControllerAnimated:YES];

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
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType, nil];
}




@end


/*

HEIGHT 


if English feet and inches:

use a form with space for feet and inches



ORKFormStep *height_step =
    [[ORKFormStep alloc] initWithIdentifier:kFormIdentifier
                                       title:@"Height"
                                        text:@"Enter height in feet and inches"];
    NSMutableArray *items = [NSMutableArray new];
    
    
    ORKNumericAnswerFormat *feet_format =
      [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"feet"];
    [items addObject:
      [[ORKFormItem alloc] initWithIdentifier:kFootItemIdentifier
                                         text:@"feet"
                                 answerFormat:feet_Format];
                                 
    ORKNumericAnswerFormat *inches_format =
      [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"inches"];
    [items addObject:
      [[ORKFormItem alloc] initWithIdentifier:kFootItemIdentifier
                                         text:@"inches"
                                 answerFormat:inches_Format];
    // ... And so on, adding additional items
    height_step.formItems = items;
    
    
if metric, just use numeric form

       ORKNumericAnswerFormat *height_format =
      [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"cm"];
    ORKQuestionStep *weight_step =
      [ORKQuestionStep questionStepWithIdentifier:kIdentifierWeight
                                            title:@"height"
                                           answer:weight_format];
                                           
                                           
*/

