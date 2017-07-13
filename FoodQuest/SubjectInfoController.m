//
//  SubjectInfoController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/28.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "SubjectInfoController.h"
#import "Firebase.h"
#import "FQUtilities.h"


@interface SubjectInfoController () {

    NSDictionary *_userInfo;
    
    FIRDatabaseHandle _firebaseRefHandle;
}

@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end


@implementation SubjectInfoController


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidAppear:(BOOL)animated; {




    NSMutableArray *steps = [NSMutableArray array];


    ORKInstructionStep *instructionStep =
      [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
      
    instructionStep.title = @"Eligibility and Subject Infomation";
    instructionStep.text = @"This survey will ask for details about you, and your general eating habits.";
    
    [steps addObject:instructionStep];


    
#define kUserAgeKey @"age"
#define kUserNameKey @"name"
#define kUserEmailKey @"email"
#define kUserSexKey @"sex"
#define kUserFavoriteFoodKey @"favoriteFood"
#define kUserWorstFoodKey @"worstFood"
#define kUserSubjectID @"subjectID"
    
    ORKOrderedTask *task =
      [[ORKOrderedTask alloc] initWithIdentifier:@"subjectTask" steps:steps];


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
    
    
    [self saveUserInfoToFirebase];
    

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // go back to main table view
    [self.tabBarController setSelectedIndex:0];
    // or set selectedViewContoller


}




- (void)saveUserInfoToFirebase; {

  _firebaseRef = [[FIRDatabase database] reference];

  // Push data to Firebase Database
  
  // NOTE: index by subjectID
  [[[_firebaseRef child:@"userInfo"] childByAutoId] setValue:_userInfo];
}
@end




