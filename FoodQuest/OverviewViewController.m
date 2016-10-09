//
//  OverviewViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "OverviewViewController.h"

@interface OverviewViewController ()

@end

@implementation OverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToMainMenu:(UIStoryboardSegue*)sender
{
    UIViewController *sourceViewController = sender.sourceViewController;
    // Pull any data from the view controller which initiated the unwind segue.
}


-(void)viewDidAppear:(BOOL)animated; {


    UIViewController *presenter = self.presentingViewController;
    [self startConsentTask];
}




-(void)startConsentTask; {

   	ORKConsentDocument *document = [ORKConsentDocument new];
 	
        
    /*
    Overview (ORKConsentSectionTypeOverview)
    Data gathering (ORKConsentSectionTypeDataGathering)
    Privacy (ORKConsentSectionTypePrivacy)
    Data use (ORKConsentSectionTypeDataUse)
    Time commitment (ORKConsentSectionTypeTimeCommitment)
    Surveys (ORKConsentSectionTypeStudySurvey)
    Tasks (ORKConsentSectionTypeStudyTasks)
    Withdrawal (ORKConsentSectionTypeWithdrawing)
    */
    
    //--------------------------------------------------------------------------------
        
        ORKConsentSection *overviewSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOverview];
        overviewSection.title = @"Overview";
        overviewSection.summary = @"Welcome to FoodQuest.";
        overviewSection.content = @"The content to show in learn more ...";
        
    //--------------------------------------------------------------------------------
        
        ORKConsentSection *dataGatheringSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataGathering];
        dataGatheringSection.title = @"Data Gathering";
        dataGatheringSection.summary = @"The summary about the section goes here ...";
        dataGatheringSection.content = @"The content to show in learn more ...";
        
    //--------------------------------------------------------------------------------

       ORKConsentSection *privacySection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypePrivacy];
        privacySection.title = @"Privacy";
        privacySection.summary = @"The summary about the section goes here ...";
        privacySection.content = @"The content to show in learn more ...";

    //--------------------------------------------------------------------------------

     ORKConsentSection *dataUseSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataUse];
        dataUseSection.title = @"Data Use";
        dataUseSection.summary = @"The summary about the section goes here ...";
        dataUseSection.content = @"The content to show in learn more ...";


    //--------------------------------------------------------------------------------

     ORKConsentSection *timeSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeTimeCommitment];
        timeSection.title = @"Time Commitment";
        timeSection.summary = @"The summary about the section goes here ...";
        timeSection.content = @"The content to show in learn more ...";

    //--------------------------------------------------------------------------------

     ORKConsentSection *surveySection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudySurvey];
        surveySection.title = @"Surveys";
        surveySection.summary = @"The summary about the section goes here ...";
        surveySection.content = @"The content to show in learn more ...";

    //--------------------------------------------------------------------------------

     ORKConsentSection *tasksSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudyTasks];
        tasksSection.title = @"Tasks";
        tasksSection.summary = @"The summary about the section goes here ...";
        tasksSection.content = @"The content to show in learn more ...";

    //--------------------------------------------------------------------------------
     ORKConsentSection *withdrawalSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeWithdrawing];
        withdrawalSection.title = @"Withdrawing";
        withdrawalSection.summary = @"The summary about the section goes here ...";
        withdrawalSection.content = @"The content to show in learn more ...";

    //--------------------------------------------------------------------------------
        
        


    // Create additional section objects for later sections
    document.sections = @[overviewSection,dataGatheringSection,privacySection,dataUseSection,timeSection,surveySection,tasksSection,withdrawalSection];

    ORKVisualConsentStep *consentStep =
      [[ORKVisualConsentStep alloc] initWithIdentifier:@"intro" document:document];

    // And then create and present a task including this step.

    consentStep.title = @"Welcome to FoodQuest";

    ORKOrderedTask *task =
      [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[consentStep]];

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


@end
