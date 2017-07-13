//
//  OverviewViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "OverviewViewController.h"
#import "FQConstants.h"

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

    [super viewDidAppear:animated];
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
        overviewSection.title = kOverviewTitle;
        overviewSection.summary = kOverviewSummary;        
        NSString *overviewPath = [[NSBundle mainBundle] pathForResource:kOverviewHTMLFile ofType:@"html"]; 
        overviewSection.htmlContent = [NSString stringWithContentsOfFile:overviewPath encoding:NSUTF8StringEncoding error:nil];

        
    //--------------------------------------------------------------------------------
        
        ORKConsentSection *dataGatheringSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataGathering];
        dataGatheringSection.title = kDataGatheringTitle;
        dataGatheringSection.summary = kDataGatheringSummary;
        NSString *dataGatheringPath = [[NSBundle mainBundle] pathForResource:kDataGatheringHTMLFile ofType:@"html"]; 
        dataGatheringSection.htmlContent = [NSString stringWithContentsOfFile:dataGatheringPath encoding:NSUTF8StringEncoding error:nil];
        
    //--------------------------------------------------------------------------------

       ORKConsentSection *privacySection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypePrivacy];
        privacySection.title = kPrivacyTitle;
        privacySection.summary = kPrivacySummary;
        NSString *privacyPath = [[NSBundle mainBundle] pathForResource:kPrivacyHTMLFile ofType:@"html"]; 
        privacySection.htmlContent = [NSString stringWithContentsOfFile:privacyPath encoding:NSUTF8StringEncoding error:nil];

    //--------------------------------------------------------------------------------

     ORKConsentSection *dataUseSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataUse];
        dataUseSection.title = kDataUseTitle;
        dataUseSection.summary = kDataUseSummary;
        NSString *dataUsePath = [[NSBundle mainBundle] pathForResource:kDataUseHTMLFile ofType:@"html"]; 
        dataUseSection.htmlContent = [NSString stringWithContentsOfFile:dataUsePath encoding:NSUTF8StringEncoding error:nil];


    //--------------------------------------------------------------------------------

     ORKConsentSection *timeSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeTimeCommitment];
        timeSection.title = kTimeTitle;
        timeSection.summary = kTimeSummary;
        NSString *timePath = [[NSBundle mainBundle] pathForResource:kTimeHTMLFile ofType:@"html"]; 
        timeSection.htmlContent = [NSString stringWithContentsOfFile:timePath encoding:NSUTF8StringEncoding error:nil];
    //--------------------------------------------------------------------------------

     ORKConsentSection *surveySection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudySurvey];
        surveySection.title = kSurveyTitle;
        surveySection.summary = kSurveySummary;
        NSString *surveyPath = [[NSBundle mainBundle] pathForResource:kSurveyHTMLFile ofType:@"html"]; 
        surveySection.htmlContent = [NSString stringWithContentsOfFile:surveyPath encoding:NSUTF8StringEncoding error:nil];
    //--------------------------------------------------------------------------------

     ORKConsentSection *tasksSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudyTasks];
        tasksSection.title = kTaskTitle;
        tasksSection.summary = kTaskSummary;
        NSString *tasksPath = [[NSBundle mainBundle] pathForResource:kTaskHTMLFile ofType:@"html"]; 
        tasksSection.htmlContent = [NSString stringWithContentsOfFile:tasksPath encoding:NSUTF8StringEncoding error:nil];
    //--------------------------------------------------------------------------------
     ORKConsentSection *withdrawalSection =
          [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeWithdrawing];
        withdrawalSection.title = kWithdrawalTitle;
        withdrawalSection.summary = kWithdrawalSummary;
        NSString *withdrawalPath = [[NSBundle mainBundle] pathForResource:kWithdrawalHTMLFile ofType:@"html"]; 
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

    [self.navigationController popToRootViewControllerAnimated:YES];

}


@end
