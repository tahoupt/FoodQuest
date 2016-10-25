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
        NSString *overviewPath = [[NSBundle mainBundle] pathForResource:@"overview_content" ofType:@"html"]; 
        overviewSection.htmlContent = [NSString stringWithContentsOfFile:overviewPath encoding:NSUTF8StringEncoding error:nil];

        
    //--------------------------------------------------------------------------------
        
        ORKConsentSection *dataGatheringSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataGathering];
        dataGatheringSection.title = @"Data Gathering";
        dataGatheringSection.summary = @"The summary about the section goes here ...";
        NSString *dataGatheringPath = [[NSBundle mainBundle] pathForResource:@"dataGathering_content" ofType:@"html"]; 
        dataGatheringSection.htmlContent = [NSString stringWithContentsOfFile:dataGatheringPath encoding:NSUTF8StringEncoding error:nil];
        
    //--------------------------------------------------------------------------------

       ORKConsentSection *privacySection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypePrivacy];
        privacySection.title = @"Privacy";
        privacySection.summary = @"The summary about the section goes here ...";
        NSString *privacyPath = [[NSBundle mainBundle] pathForResource:@"privacy_content" ofType:@"html"]; 
        privacySection.htmlContent = [NSString stringWithContentsOfFile:privacyPath encoding:NSUTF8StringEncoding error:nil];

    //--------------------------------------------------------------------------------

     ORKConsentSection *dataUseSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataUse];
        dataUseSection.title = @"Data Use";
        dataUseSection.summary = @"The summary about the section goes here ...";
        NSString *dataUsePath = [[NSBundle mainBundle] pathForResource:@"dataUse_content" ofType:@"html"]; 
        dataUseSection.htmlContent = [NSString stringWithContentsOfFile:dataUsePath encoding:NSUTF8StringEncoding error:nil];


    //--------------------------------------------------------------------------------

     ORKConsentSection *timeSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeTimeCommitment];
        timeSection.title = @"Time Commitment";
        timeSection.summary = @"The summary about the section goes here ...";
        NSString *timePath = [[NSBundle mainBundle] pathForResource:@"time_content" ofType:@"html"]; 
        timeSection.htmlContent = [NSString stringWithContentsOfFile:timePath encoding:NSUTF8StringEncoding error:nil];
    //--------------------------------------------------------------------------------

     ORKConsentSection *surveySection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudySurvey];
        surveySection.title = @"Surveys";
        surveySection.summary = @"The summary about the section goes here ...";
        NSString *surveyPath = [[NSBundle mainBundle] pathForResource:@"survey_content" ofType:@"html"]; 
        surveySection.htmlContent = [NSString stringWithContentsOfFile:surveyPath encoding:NSUTF8StringEncoding error:nil];
    //--------------------------------------------------------------------------------

     ORKConsentSection *tasksSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudyTasks];
        tasksSection.title = @"Tasks";
        tasksSection.summary = @"The summary about the section goes here ...";
        NSString *tasksPath = [[NSBundle mainBundle] pathForResource:@"tasks_content" ofType:@"html"]; 
        tasksSection.htmlContent = [NSString stringWithContentsOfFile:tasksPath encoding:NSUTF8StringEncoding error:nil];
    //--------------------------------------------------------------------------------
     ORKConsentSection *withdrawalSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeWithdrawing];
        withdrawalSection.title = @"Withdrawing";
        withdrawalSection.summary = @"The summary about the section goes here ...";
        NSString *withdrawalPath = [[NSBundle mainBundle] pathForResource:@"withdrawal_content" ofType:@"html"]; 
        withdrawalSection.htmlContent = [NSString stringWithContentsOfFile:withdrawalPath encoding:NSUTF8StringEncoding error:nil];
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
