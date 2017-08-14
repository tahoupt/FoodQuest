//
//  ConsentViewController.m
//  FoodSurve
//
//  Created by Tom Houpt on 16/9/27.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "ConsentViewController.h"
#import "YesNoAction.h"
#import "Firebase.h"
#import "FQUtilities.h"
#import "FQConstants.h"


@interface ConsentViewController () {

}



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

    [super viewDidAppear:animated];
    [self startConsentReviewTask];
}




#define kConsentReviewStepIdentifier @"consentReview"
#define kConsentSharingIdentifier @"consentSharing"
#define kparticipantEmailIdentifier @"participantEmail"

-(void)startConsentReviewTask; {


//    ORKConsentSharingStep *sharingStep =
//          [[ORKConsentSharingStep alloc] initWithIdentifier:kConsentSharingIdentifier
//                               investigatorShortDescription:@"MyInstitution"
//                                investigatorLongDescription:@"MyInstitution and its partners"
//                              localizedLearnMoreHTMLContent:@"Lorem ipsum..."];
//                          

// get userid, email, and phone number:

     ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:@"Enrollment Form"
                                       title:@"Form"
                                        text:@"Form groups multi-entry in one page"];
    NSMutableArray *items = [NSMutableArray new];
    
    ORKAnswerFormat *userIdFormat = [[ORKTextAnswerFormat alloc] initWithMaximumLength:15];
    ORKFormItem *useridItem = [[ORKFormItem alloc] initWithIdentifier:@"useridItem"
                                         text:@"User ID (from your invitation)"
                                 answerFormat:userIdFormat];
    useridItem.placeholder = @"userid";
    useridItem.optional = NO;
    [items addObject:useridItem];
    
    ORKAnswerFormat *emailFormat = [[ORKEmailAnswerFormat alloc] init];
    ORKFormItem *emailItem = [[ORKFormItem alloc] initWithIdentifier:@"emailItem"
                                         text:@"Email Address (for receiving study info)"
                                 answerFormat:emailFormat];
    emailItem.placeholder = @"me@email.com";
    emailItem.optional = NO;
    [items addObject:emailItem];
    
    
    ORKAnswerFormat *phoneFormat = [[ORKTextAnswerFormat alloc] initWithMaximumLength:15];
    ORKFormItem *phoneItem = [[ORKFormItem alloc] initWithIdentifier:@"phoneItem"
                                         text:@"Phone number (for receiving text reminders)"
                                 answerFormat:phoneFormat];
    phoneItem.placeholder = @"(012)345-6789";
    phoneItem.optional = NO;
    [items addObject:phoneItem];
    
    formStep.formItems = items;
    
    _consent = [[ORKConsentDocument alloc] init];
    _consent.title = [NSString stringWithFormat:@"%@ Consent",kStudyTitle];
    _consent.signaturePageTitle = [NSString stringWithFormat:@"Signature Page for Consent for %@ Study",kStudyTitle];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"consent_review" ofType:@"html"]; 
    _consent.htmlReviewContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    // a blank signature line for the subject (to be filled in on consent form)
    ORKConsentSignature *nameSignature = [ORKConsentSignature signatureForPersonWithTitle:@"Study Participant" dateFormatString:@"yyyy-MM-dd 'at' HH:mm" identifier:@"subjectSignatureType"];
    nameSignature.requiresName = YES;
    nameSignature.requiresSignatureImage = YES;
    [_consent addSignature:nameSignature];

    // a second signature could be added that is pre-populated with e.g. the principal investigators name, title, and signature image
//    ORKConsentSignature *sigSignature = [ORKConsentSignature signatureForPersonWithTitle:nil dateFormatString:nil identifier:@"subjectSignatureImage"];
//    sigSignature.requiresSignatureImage = YES;
//    
//    [_consent addSignature:sigSignature];
//
    

    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:kConsentReviewStepIdentifier
        signature:_consent.signatures[0] 
        inDocument:_consent];
    
    reviewStep.text = [NSString stringWithFormat:@"%@ Consent",kStudyTitle];     
     
    reviewStep.reasonForConsent = @"By agreeing, you confirm that you have read and understand the information in the overview, and that you wish to take part in this research study.";
    
  
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"consent_task" steps:@[reviewStep]];

    _taskViewController =  [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    _taskViewController.delegate = self;
    [self presentViewController:_taskViewController animated:YES completion:nil];



}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {


        if (reason  != ORKTaskViewControllerFinishReasonCompleted) {
        
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            ORKTaskResult *taskResult = [taskViewController result];

            ORKStepResult *stepResult = [taskResult stepResultForStepIdentifier:kConsentReviewStepIdentifier];

            ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[stepResult.results firstObject];
          
          // NOTE: IMPORTANT ! apply signatureResult to a copy of the consent document!
           ORKConsentDocument *consentCopy = [_consent copy];
           
            [signatureResult applyToDocument:consentCopy];
            


        // get subjects name & signing dates out of the signatureResult
           [[NSUserDefaults standardUserDefaults] setObject: signatureResult.signature.givenName forKey: kUserFirstNameKey];
           [[NSUserDefaults standardUserDefaults] setObject: signatureResult.signature.familyName forKey: kUserLastNameKey];
           [[NSUserDefaults standardUserDefaults] setObject: signatureResult.signature.title forKey: kUserTitleKey];
           [[NSUserDefaults standardUserDefaults] setObject: signatureResult.signature.signatureDate forKey: kUserGaveConsentDateKey];
           [[NSUserDefaults standardUserDefaults] setObject: signatureResult.signature.signatureDateFormatString forKey: kUserGaveConsentDateFormatKey];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUserParticipatingFlagKey];

            
            // Then, dismiss the task view controller.
            
        //   [self dismissViewControllerAnimated:YES completion:^{
                
                NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey];
                
                if (nil == user_id) { user_id = @"thoupt";}
                
                if (nil == user_id) {
                    // TODO: put up alert that without recruitment user_id, consent won't be saved.
                    
                }
                else {

                    [consentCopy makePDFWithCompletionHandler:^(NSData * new_pdfFile, NSError * error) {
                     
                        self.pdfFile = new_pdfFile;
                            
                //        // write pdf to temp directory
                //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                //        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"FoodSurveConsent.pdf"];
                //        [self.pdfFile writeToFile:filePath options:NSDataWritingAtomic error:nil];
                
                        [self putPDFinFirebaseStorage];
                        
                         

                         
                         // TODO: store consent date/participation in firebase
                        [self wantsPDFEmailed];


                    }];   //   makePDFWithCompletionHandler

                } // has user_id
            
     //   }]; // dismiss the task view controller.

        
        } // ORKTaskViewControllerFinishReasonCompleted 


        // popping view controller will be handled in sendemail callbacks

}


    
-(void)wantsPDFEmailed; {

        _alert = [UIAlertController alertControllerWithTitle:@"Signed Consent Form"
                                   message:@"Would you like the signed consent form emailed to you as a PDF file?"
                                   preferredStyle:UIAlertControllerStyleAlert];
     
        YesNoAction* defaultAction = [YesNoAction actionWithTitle:@"Yes, Send Email"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) { 
                                                        [((YesNoAction *)action).parent yesAction]; 
                                                    }];
     
       
        YesNoAction* cancelAction = [YesNoAction actionWithTitle:@"No"
                                                 style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * action) {
                                                        [((YesNoAction *)action).parent noAction]; 
                                                    }];  
                                                              
        defaultAction.parent = self;
        cancelAction.parent = self;

        [_alert addAction:defaultAction];
        [_alert addAction:cancelAction];
        
        
        [_taskViewController presentViewController:_alert animated:YES completion:nil];

}

-(void)yesAction; {

     //  [_taskViewController dismissViewControllerAnimated:YES completion:nil];

        [self sendPDFEmail];

}

-(void)noAction; {
       [_taskViewController dismissViewControllerAnimated:YES completion:nil];

        [self closeViewController];
}


-(void)sendPDFEmail {

        if (![MFMailComposeViewController canSendMail]) {
           //  TODO: put up alert that email not available
           NSLog(@"Mail services are not available.");
           [self closeViewController];

           return;
        }

        MFMailComposeViewController* pdfEmail = [[MFMailComposeViewController alloc] init];
        pdfEmail.mailComposeDelegate = self;
         
        // Configure the fields of the interface.
        [pdfEmail setToRecipients:@[@"address@example.com"]];
        [pdfEmail setSubject: [NSString stringWithFormat:@"Signed %@ Consent Form",kStudyTitle] ];
        [pdfEmail setMessageBody:@"" isHTML:NO];
         
        [pdfEmail addAttachmentData:self.pdfFile mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@Consent.pdf",kStudyShortTitle]];


        // Present the view controller modally.
        [_taskViewController presentViewController:pdfEmail animated:YES completion:nil];


}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
       // Check the result or perform other tasks.
     
       // Dismiss the mail compose view controller.
       [_taskViewController dismissViewControllerAnimated:YES completion:^{        
       // dismiss the taskviewcontroller and pop
            [self closeViewController];
       }];

}


-(void) putPDFinFirebaseStorage; {

        // Create a path to "consent/<userid>_consent.pdf"
        NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey];
        NSString *consent_file_path = [NSString stringWithFormat:@"%@/consent/%@_consent.pdf",kFirebaseDirectory,user_id];
            
        // Get a reference to the storage service, using the default Firebase App
        FIRStorage *storage = [FIRStorage storage];
        FIRStorageReference *consentDocRef = [storage referenceWithPath:consent_file_path];


    //    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info.plist" ofType:@"plist"];
    //    NSDictionary *googleServiceInfo = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    //    NSString *storageBucketName = [googleServiceInfo objectForKey:@"STORAGE_BUCKET"];
    //    NSString *storageURL = [NSString stringWithFormat:@"gs://%@",storageBucketName];
    //
    //
    //    // Create a storage reference from our storage service
    //    FIRStorageReference *storageRef = [storage referenceForURL:storageURL];

        
        // Upload the file to the path
        
        FIRStorageUploadTask *uploadTask = [consentDocRef putData:self.pdfFile metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                // NOTE: store this url in the user's firebase database entry
                NSURL *downloadURL = metadata.downloadURL;
                [[NSUserDefaults standardUserDefaults] setObject:[downloadURL absoluteString] forKey: kUserConsentPDFLinkKey];
                
                // since we saved the consent, we can now create the subject record
                SaveSubjectToFirebase();
            }
        }];
}

-(void)closeViewController; {
        // dismiss the taskviewcontroller and pop
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
       // NOTE: Unbalanced calls to begin/end appearance transitions for <ConsentViewController: 
       // try poping without animation?
}


@end
