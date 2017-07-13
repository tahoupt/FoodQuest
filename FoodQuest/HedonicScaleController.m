//
//  HedonicScaleController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/9.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "HedonicScaleController.h"
#import "ImageHedonicScaleAnswerFormat.h"
#import "foodpics.h"
#import "Firebase.h"
#import "FQUtilities.h"
#import "LMSScaleLabel.h"


 @interface HedonicScaleController () {
  FIRDatabaseHandle _firebaseRefHandle;
  NSMutableArray<LMSScaleLabel *> *_hedonicScaleLabels;
  
   NSMutableArray<LMSScaleLabel *> *_natickScaleLabels;
  
}

@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end



@implementation HedonicScaleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureDatabase];
}


-(void)viewDidAppear:(BOOL)animated; {



    NSMutableArray *steps = [NSMutableArray array];


    ORKInstructionStep *instructionStep =
      [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
      
    instructionStep.title = @"Food Rating";
    instructionStep.text = @"This survey will ask you to rate your liking for foods.";
    
    [steps addObject:instructionStep];


#define kIdentifierRating @"rating_1024"

  // NOTE: we need to make modified ORKScaleSliderView into a subclass with a subclass
// of ORKContinuousScaleAnswerFormat --> ContinuousLinearMagnitudeScale

   
   LHSImageScaleAnswerFormat *scaleFormat =  [[LHSImageScaleAnswerFormat alloc]initWithImageIndex:213 imageType:@"jpg" imageLabel:@"" showImageLabel:YES];
    
    ORKQuestionStep *ratingStep = [ORKQuestionStep questionStepWithIdentifier:kIdentifierRating title:@"How would you rate this food?"  answer:scaleFormat];

    
    [steps addObject:ratingStep];

   NatickImageScaleAnswerFormat *natickFormat =  [[NatickImageScaleAnswerFormat alloc]initWithImageIndex:220 imageType:@"jpg" imageLabel:@""  showImageLabel:YES];
    
    ORKQuestionStep *natickRatingStep = [ORKQuestionStep questionStepWithIdentifier:@"natickrating" title:@"How would you rate this food?"  answer:natickFormat];

    
    [steps addObject:natickRatingStep];


    
    ORKOrderedTask *task =
      [[ORKOrderedTask alloc] initWithIdentifier:@"preferenceTask" steps:steps];


    ORKTaskViewController *taskViewController =
      [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [self presentViewController:taskViewController animated:YES completion:nil];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {

    ORKTaskResult *taskResult = [taskViewController result];
    // You could do something with the result here.


    NSMutableDictionary *resultDictionary = FQTaskResultToDictionary(taskResult,nil);
    
    
    [self saveResultToFirebase:resultDictionary];
    

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // go back to main table view
//    [self.tabBarController setSelectedIndex:0];
    // or set selectedViewContoller

 [self.navigationController popToRootViewControllerAnimated:YES];



}

- (void)configureDatabase {
  _firebaseRef = [[FIRDatabase database] reference];
}



- (void)saveResultToFirebase:(NSDictionary *)result_data {

  // Push data to Firebase Database
  [[[_firebaseRef child:@"hedonics"] childByAutoId] setValue:result_data];
}

@end
