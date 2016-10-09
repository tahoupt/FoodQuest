//
//  PreferenceViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "PreferenceViewController.h"
#import "foodpics.h"

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
      [[ORKInstructionStep alloc] initWithIdentifier:@"identifier"];
      
    instructionStep.title = @"Preference Survey";
    instructionStep.text = @"This survey will ask you about your food preferences.";
    
    [steps addObject:instructionStep];


//    ORKImageChoice *image1 = [ORKImageChoice choiceWithNormalImage: [UIImage imageNamed:@"cheeseburger.jpeg"] selectedImage:[self framedImageNamed:@"cheeseburger.jpeg"] text:@"cheeseburger" value:@"cheeseburger"];
//
//    ORKImageChoice *image2 =  [ORKImageChoice choiceWithNormalImage: [UIImage imageNamed:@"salad.jpeg"] selectedImage: [self framedImageNamed:@"salad.jpeg"] text:@"salad" value:@"salad"];
//         
//    ORKImageChoiceAnswerFormat *imageFormat = [[ORKImageChoiceAnswerFormat alloc]initWithImageChoices:@[image1,image2] ];
//
//    ORKQuestionStep *preferenceStep = [ORKQuestionStep questionStepWithIdentifier:kIdentifierFoodChoice title:@"Which food would you prefer right now?"  answer:imageFormat];
//    
    
#define numFoodPictures 896
#define numObjectPictures 418
#define numPreferenceSteps 1

    for (NSInteger i = 0; i < numPreferenceSteps; i++) {
    
        NSString *identifier = [NSString stringWithFormat:@"IndexPreference_%ld",i];
        
        
        // NOTE: we need to make modified ORKImageChoiceAnswerFormat into a subclass
        ORKImageChoiceAnswerFormat *randomFoodImageFormat = [self randomFoodImageChoice];

        ORKQuestionStep *preferenceStep = [ORKQuestionStep questionStepWithIdentifier:identifier title:@"Which food would you prefer right now?"  answer:randomFoodImageFormat];
        
        [steps addObject:preferenceStep];

    }
    
//    ORKScaleAnswerFormat *scaleFormat = [[ORKScaleAnswerFormat alloc] initWithMaximumValue:10 minimumValue:-10 defaultValue:0 step:2  vertical:YES maximumValueDescription:@"Delicious" minimumValueDescription:@"Disgusting"];
//    
//    ORKQuestionStep *ratingStep = [ORKQuestionStep questionStepWithIdentifier:kIdentifierPrefence title:@"How would you rate this food?"  answer:scaleFormat];
//        
//        [steps addObject:ratingStep];

// NOTE: we need to make modified ORKScaleSliderView into a subclass with a subclass
// of ORKContinuousScaleAnswerFormat --> ContinuousLinearMagnitudeScale

// NOTE: this should be rewritten to include scalelabels array and imageName
   ORKContinuousScaleAnswerFormat *scaleFormat2 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:-100 defaultValue:0 maximumFractionDigits:0 vertical:YES maximumValueDescription:@"Top" minimumValueDescription:@"Bottom"];
    
    ORKQuestionStep *ratingStep2 = [ORKQuestionStep questionStepWithIdentifier:kIdentifierPrefence2 title:@"How would you rate this food?"  answer:scaleFormat2];

    
    [steps addObject:ratingStep2];

    
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


-(ORKImageChoiceAnswerFormat *)imageChoiceWithImageIndex1:(NSInteger)index1 andImageIndex2:(NSInteger)index2; {


    NSString *imageName1 = [NSString stringWithFormat:@"%04ld.jpg",index1];
    NSString *imageName2 = [NSString stringWithFormat:@"%04ld.jpg",index2];
    NSString *value1 =  [NSString stringWithFormat:@"%04ld",index1];
    NSString *value2 =  [NSString stringWithFormat:@"%04ld",index2];

    
    ORKImageChoice *image1 = [ORKImageChoice choiceWithNormalImage: [UIImage imageNamed:imageName1] selectedImage:[self framedImageNamed:imageName1] text:value1 value:value1];

    ORKImageChoice *image2 =  [ORKImageChoice choiceWithNormalImage: [UIImage imageNamed:imageName2] selectedImage: [self framedImageNamed:imageName2] text:value2 value:value2];
         
    ORKImageChoiceAnswerFormat *imageFormat = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:@[image1,image2] ];
 

    return imageFormat;

}

-(ORKImageChoiceAnswerFormat *)randomFoodImageChoice; {

    NSInteger index1 = arc4random_uniform(numFoodPictures) + 1;
    NSInteger index2 = arc4random_uniform(numFoodPictures) + 1;
        
    // make sure they are non-identical indexes
    while (index2 == index1) {
        index2 = arc4random_uniform(numFoodPictures) + 1;
    }
    
    return [self imageChoiceWithImageIndex1:index1 andImageIndex2:index2];

}


@end
