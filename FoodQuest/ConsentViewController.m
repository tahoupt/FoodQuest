//
//  ConsentViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/27.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "ConsentViewController.h"
#import "YesNoAction.h"

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



    _consent = [[ORKConsentDocument alloc] init];
    _consent.title = @"FoodQuest Consent";
    _consent.signaturePageTitle = @"FoodQuest Signature for Consent";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"consent_review" ofType:@"html"]; 
    _consent.htmlReviewContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    
    ORKConsentSignature *nameSignature = [ORKConsentSignature signatureForPersonWithTitle:nil dateFormatString:nil identifier:@"subjectSignatureType"];
    nameSignature.requiresName = YES;

    [_consent addSignature:nameSignature];


    ORKConsentSignature *sigSignature = [ORKConsentSignature signatureForPersonWithTitle:nil dateFormatString:nil identifier:@"subjectSignatureImage"];
    sigSignature.requiresSignatureImage = YES;
    
    [_consent addSignature:sigSignature];

    

    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:kConsentReviewIdentifier
        signature:_consent.signatures[0] 
        inDocument:_consent];
    
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


    if (reason  != ORKTaskViewControllerFinishReasonCompleted) {
        return;
    }
    ORKTaskResult *taskResult = [taskViewController result];
    // You could do something with the result here.


ORKStepResult *stepResult = [taskResult stepResultForStepIdentifier:@"ConsentReviewStep"];

  ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[stepResult.results firstObject];
  
    [signatureResult applyToDocument:_consent];

     [_consent makePDFWithCompletionHandler:^(NSData * new_pdfFile, NSError * error) {
     
            self.pdfFile = new_pdfFile;
        // write pdf to temp directory
        
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
             NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"FoodQuestConsent.pdf"];
             [self.pdfFile writeToFile:filePath options:NSDataWritingAtomic error:nil];


            [self wantsPDFEmailed];


        }];    

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // go back to main table view
    [self.tabBarController setSelectedIndex:0];
    // or set selectedViewContoller

}
    
-(void)wantsPDFEmailed; {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Signed Consent Form"
                               message:@"Would you like the signed consent form emailed to you as a PDF file?"
                               preferredStyle:UIAlertControllerStyleAlert];
 
    YesNoAction* defaultAction = [YesNoAction actionWithTitle:@"Yes, Send Email"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) { [((YesNoAction *)action).parent yesAction]; }];
 
   
    YesNoAction* cancelAction = [YesNoAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];  
                                                          
    defaultAction.parent = self;
    cancelAction.parent = self;

    [alert addAction:defaultAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];

}

-(void)yesAction; {

    [self sendPDFEmail];

}

-(void)sendPDFEmail {

       if (![MFMailComposeViewController canSendMail]) {
           NSLog(@"Mail services are not available.");
           return;
        }

        MFMailComposeViewController* pdfEmail = [[MFMailComposeViewController alloc] init];
        pdfEmail.mailComposeDelegate = self;
         
        // Configure the fields of the interface.
        [pdfEmail setToRecipients:@[@"address@example.com"]];
        [pdfEmail setSubject:@"Signed FoodQuest Consent Form"];
        [pdfEmail setMessageBody:@"" isHTML:NO];
         
        [pdfEmail addAttachmentData:self.pdfFile mimeType:@"application/pdf" fileName:@"FoodQuestConsent.pdf"];


        // Present the view controller modally.
        [self presentViewController:pdfEmail animated:YES completion:nil];


}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
   // Check the result or perform other tasks.
 
   // Dismiss the mail compose view controller.
   [self dismissViewControllerAnimated:YES completion:nil];
}

@end
