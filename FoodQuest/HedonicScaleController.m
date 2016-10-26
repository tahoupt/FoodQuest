//
//  HedonicScaleController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/9.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "HedonicScaleController.h"
#import "foodpics.h"
#import "Firebase.h"
#import "FQUtilities.h"
#import "LMSScaleLabel.h"


 @interface HedonicScaleController () {
  FIRDatabaseHandle _firebaseRefHandle;
  NSMutableArray<LMSScaleLabel *> *_hedonicScaleLabels;
  
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


 
    [self setUpHedonicScaleLabels];
    


    NSMutableArray *steps = [NSMutableArray array];


    ORKInstructionStep *instructionStep =
      [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
      
    instructionStep.title = @"Food Rating";
    instructionStep.text = @"This survey will ask you to rate your liking for foods.";
    
    [steps addObject:instructionStep];


#define kIdentifierRating @"rating_1024"

  // NOTE: we need to make modified ORKScaleSliderView into a subclass with a subclass
// of ORKContinuousScaleAnswerFormat --> ContinuousLinearMagnitudeScale

// NOTE: this should be rewritten to include scalelabels array and imageName
   ORKContinuousScaleAnswerFormat *scaleFormat = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:-100 defaultValue:0 maximumFractionDigits:0 vertical:YES maximumValueDescription:@"Top" minimumValueDescription:@"Bottom"];
    
    ORKQuestionStep *ratingStep = [ORKQuestionStep questionStepWithIdentifier:kIdentifierRating title:@"How would you rate this food?"  answer:scaleFormat];

    
    [steps addObject:ratingStep];

    
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


  NSMutableDictionary *resultDictionary = TaskResultToDictionary(taskResult);
    
    // some user identifier, but anonymized?
    resultDictionary[@"user_id"] = @"thoupt"; 
    
    [self saveResultToFirebase:resultDictionary];
    

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // go back to main table view
    [self.tabBarController setSelectedIndex:0];
    // or set selectedViewContoller


}

- (void)configureDatabase {
  _firebaseRef = [[FIRDatabase database] reference];
}



- (void)saveResultToFirebase:(NSDictionary *)result_data {

  // Push data to Firebase Database
  [[[_firebaseRef child:@"hedonics"] childByAutoId] setValue:result_data];
}

-(void)setUpHedonicScaleLabels; {

 NSArray *LHS_labels = @[
        
            @"Most Liked Imaginable",
            @"Like Extremely",
            @"Like Very Much",
            @"Like Moderately",
            @"Like Slightly",
            @"Dislike Slightly",
            @"Dislike Moderately",
            @"Dislike Very Much",
            @"Dislike Extremely",
            @"Most Disliked Imaginable"

        ];


        NSArray *LHS_scale_s = @[
            @100.00,
            @65.72,
            @44.43,
            @17.82,
            @6.25,
            @-5.92,
            @-17.59,
            @-41.58,
            @-62.89,
            @-100.00
        ];

        _hedonicScaleLabels = [NSMutableArray array];

//        for (int i = 0; i< [LHS_labels count]; i++) {
//           LMSScaleLabel *scale_label = [[LMSScaleLabel alloc] initWithText:[LHS_labels objectAtIndex:i ] andPosition:  [[LHS_scale_s objectAtIndex:i ] doubleValue]];
//            [_hedonicScaleLabels addObject: scale_label];
//
//        }

}
@end
