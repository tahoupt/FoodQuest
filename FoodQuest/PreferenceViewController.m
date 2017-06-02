//
//  PreferenceViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "PreferenceViewController.h"
#import "foodpics.h"
#import "Firebase.h"
#import "FQUtilities.h"
#import "FQConstants.h"


#import "ImagePreferenceStepViewController.h"
#import "ImagePreferenceQuestionView.h"
#import "ImagePreferenceChoice.h"
#import "ImagePreferenceChoiceAnswerFormat.h"


//---------------------------------------------------------------
//---------------------------------------------------------------


@interface PreferenceViewController () 
@end

@implementation PreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define kIdentifierFoodChoice @"FoodChoice"
#define kIdentifierIndexFoodChoice @"IndexFoodChoice"
#define kIdentifierPrefence @"Preference"
#define kIdentifierPrefence2 @"Preference2"

-(void)viewDidAppear:(BOOL)animated; {




    NSMutableArray *steps = [NSMutableArray array];


    ORKInstructionStep *instructionStep =
      [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
      
    instructionStep.title = @"Preference Survey";
    instructionStep.text = @"This survey will ask you about your food preferences.";
    
    [steps addObject:instructionStep];


//    ORKImageChoice *image1 = [ORKImageChoice choiceWithNormalImage: [UIImage imageNamed:@"cheeseburger.jpeg"] selectedImage:[self framedImageNamed:@"cheeseburger.jpeg"] text:@"cheeseburger" value:@"cheeseburger"];
//
//    ORKImageChoice *image2 =  [ORKImageChoice choiceWithNormalImage: [UIImage imageNamed:@"salad.jpeg"] selectedImage: [self framedImageNamed:@"salad.jpeg"] text:@"salad" value:@"salad"];
//         
//    ImagePreferenceChoiceAnswerFormat *imageFormat = [[ImagePreferenceChoiceAnswerFormat alloc]initWithImageChoices:@[image1,image2] ];
//
//    ORKQuestionStep *preferenceStep = [ORKQuestionStep questionStepWithIdentifier:kIdentifierFoodChoice title:@"Which food would you prefer right now?"  answer:imageFormat];
//    
    
#define numFoodPictures 896
#define numObjectPictures 418
#define numPreferenceSteps 3

    for (NSInteger i = 0; i < numPreferenceSteps; i++) {
    
        NSString *identifier = [NSString stringWithFormat:@"preference_%ld",i];
        
        
        // NOTE: we need to make modified ImagePreferenceChoiceAnswerFormat into a subclass
        ImagePreferenceChoiceAnswerFormat *randomFoodImageFormat = [self randomFoodImageChoice];

        ORKQuestionStep *preferenceStep = [ORKQuestionStep questionStepWithIdentifier:identifier title:@"Which food would you prefer right now?"  answer:randomFoodImageFormat];
        
        [steps addObject:preferenceStep];

    }
    
    
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
    
    
    NSMutableDictionary *resultDictionary = FQTaskResultToDictionary(taskResult);
    
    
    [self saveResultToFirebase:resultDictionary];
    

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // go back to main table view
    [self.tabBarController setSelectedIndex:0];
    // or set selectedViewContoller


}

-(UIImage*) framedImageNamed:(NSString *) imageName;
{

    UIImage* bgImage = [UIImage imageNamed:imageName];
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
     UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height),3,3)];
    
    [path setLineWidth:6];
    [[UIColor blueColor] setStroke];
    [path stroke];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}


-(ImagePreferenceChoiceAnswerFormat *)imageChoiceWithImageIndex1:(NSInteger)index1 andImageIndex2:(NSInteger)index2 showNoPreferenceButton:(BOOL)noPrefFlag;  {

NSString *imageName1 = [NSString stringWithFormat:@"%ld.jpg",index1];
    NSString *imageName2 = [NSString stringWithFormat:@"%ld.jpg",index2];
    NSString *value1 =  [NSString stringWithFormat:@"%ld",index1];
    NSString *value2 =  [NSString stringWithFormat:@"%ld",index2];

    
    ImagePreferenceChoice *image1 = [ImagePreferenceChoice choiceWithNormalImage: [UIImage imageNamed:imageName1] selectedImage:[self framedImageNamed:imageName1] text:value1 value:value1];

    ImagePreferenceChoice *image2 =  [ImagePreferenceChoice choiceWithNormalImage: [UIImage imageNamed:imageName2] selectedImage: [self framedImageNamed:imageName2] text:value2 value:value2];
         
    ImagePreferenceChoiceAnswerFormat *imageFormat = [[ImagePreferenceChoiceAnswerFormat alloc] initWithImageChoices:@[image1,image2] ];
    
    [imageFormat setAllowNoPreference:NO];
     [imageFormat setShowSelectedAnswer:NO];

    return imageFormat;

}

-(ImagePreferenceChoiceAnswerFormat *)imageChoiceWithImageIndex1:(NSInteger)index1 andImageIndex2:(NSInteger)index2 ;  {

    return [self imageChoiceWithImageIndex1:index1 andImageIndex2:index2 showNoPreferenceButton:NO];
 

}

-(ImagePreferenceChoiceAnswerFormat *)randomFoodImageChoice; {

    NSInteger index1 = arc4random_uniform(numFoodPictures) + 1;
    NSInteger index2 = arc4random_uniform(numFoodPictures) + 1;
        
    // make sure they are non-identical indexes
    while (index2 == index1) {
        index2 = arc4random_uniform(numFoodPictures) + 1;
    }
    
    
    return [self imageChoiceWithImageIndex1:index1 andImageIndex2:index2];

}


- (nullable ORKStepViewController *)taskViewController:(ORKTaskViewController *)taskViewController viewControllerForStep:(ORKStep *)step; {

    // return a custom view controller
    
    NSLog(@"Step ID: %@", [step identifier]);
    
    
    // see bug in line 468 of ORKQuestionStepViewController assert
    
     if (!step || ![step isKindOfClass:[ORKQuestionStep class]]) {
     
        return nil;
    }
     
     return nil;
     
//    ImagePreferenceStepViewController *stepViewCtrlr = [[ImagePreferenceStepViewController alloc] initWithStep:step];
//    
//    ImagePreferenceQuestionView *selectionView = [ [ImagePreferenceQuestionView alloc] initWithImageChoiceAnswerFormat:[self randomFoodImageChoice] answer:nil];
//
//  //  ImagePreferenceQuestionView *selectionView = [[ImagePreferenceQuestionView alloc] init];
//
//    [stepViewCtrlr setCustomQuestionView:selectionView ];
//    return stepViewCtrlr;


}



- (void)saveResultToFirebase:(NSDictionary *)result_data {

    // only save to database if we have recruitment userid
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultUserIDKey];
  
    if (nil != userID){
        
      FIRDatabaseReference *firebaseRef = [[FIRDatabase database] reference];
      
      // Push data to Firebase Database
      [[[firebaseRef child:@"preferences"] childByAutoId] setValue:result_data];

    }
  
}
@end



