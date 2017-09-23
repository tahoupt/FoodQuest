//
//  WithdrawViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/7/10.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "WithdrawViewController.h"
#import "FQConstants.h"
#import "FQUtilities.h"

@interface WithdrawViewController ()

@end

@implementation WithdrawViewController

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
    
    if (_withdrawFormHasBeenPresented) {
        return;
    }
    
    NSMutableArray *steps = [NSMutableArray array];

    ORKInstructionStep *instructionStep =
      [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
      
    instructionStep.title = [NSString stringWithFormat:@"Are you sure you want to withdraw from %@?",kStudyTitle];
    instructionStep.text = @"Withdrawing from the study will reset the app to its original state (before you joined the study).";
    
    [steps addObject:instructionStep];
    
    ORKCompletionStep *completionStep = [[ORKCompletionStep alloc] initWithIdentifier: @"Withdraw"];
    
    completionStep.title = @"We appreciate your time.";    
    completionStep.text = @"Thank you for your contribution to this study. We are sorry that you could not continue.";
        
    [steps addObject:completionStep];


    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"withdrawalTask"steps:steps];

    // start task with our subclass of ORKTaskViewController, so that it can act as StepViewControllerDelegate
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [self presentViewController:taskViewController animated:YES completion:nil];
    _withdrawFormHasBeenPresented = YES;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {

    
    BOOL completedTask = NO;
    
    if (ORKTaskViewControllerFinishReasonFailed == reason) {
        // error detected
    
        completedTask = NO;
        
        // TODO:
        // SaveErrorResultToFirebase(resultDictionary);
        

    }
    else if (ORKTaskViewControllerFinishReasonDiscarded == reason) {
        // cancelled, and user asked for result s to be discarded

        completedTask = NO;

        // TODO:
        // SaveCancelledResultToFirebase(resultDictionary);

    }
    else if (ORKTaskViewControllerFinishReasonCompleted == reason || ORKTaskViewControllerFinishReasonSaved == reason ) {
    
        completedTask = YES;
    
    
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue] forKey:kUserWithdrawalDateKey];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kUserParticipatingFlagKey];
                         
        WithdrawSubjectFromFirebase();
        
        // TODO: remove userdefaults for all the other fields, too?
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserIDKey];
    }

// Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:^{ 
         // go back to main table view
         [self.navigationController popToRootViewControllerAnimated:YES];
    
    }];
    
   
}

@end
