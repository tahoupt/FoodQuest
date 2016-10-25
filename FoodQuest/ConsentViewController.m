//
//  ConsentViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/27.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "ConsentViewController.h"

@interface ConsentViewController ()

@end

@implementation ConsentViewController

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


    [self startConsentReviewTask];
}




#define kConsentReviewIdentifier @"consentReview"

-(void)startConsentReviewTask; {



    ORKConsentDocument *consent = [[ORKConsentDocument alloc] init];
    consent.title = @"FoodQuest Consent";
    consent.signaturePageTitle = @"FoodQuest Signature for Consent";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"consent_review" ofType:@"html"]; 
    consent.htmlReviewContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    
    ORKConsentSignature *nameSignature = [ORKConsentSignature signatureForPersonWithTitle:nil dateFormatString:nil identifier:@"subjectSignatureType"];
    nameSignature.requiresName = YES;

    [consent addSignature:nameSignature];


    ORKConsentSignature *sigSignature = [ORKConsentSignature signatureForPersonWithTitle:nil dateFormatString:nil identifier:@"subjectSignatureImage"];
    sigSignature.requiresSignatureImage = YES;
    
    [consent addSignature:sigSignature];

    

    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:kConsentReviewIdentifier
        signature:consent.signatures[0] 
        inDocument:consent];
    
    reviewStep.text = @"Consent for Food Quest";     
     
    reviewStep.reasonForConsent = @"By agreeing, you confirm that you have read and understand the information in the overview, and that you wish to take part in this research study.";
    
  
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"consent_task" steps:@[reviewStep]];

    ORKTaskViewController *taskViewController =  [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
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
