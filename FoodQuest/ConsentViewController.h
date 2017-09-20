//
//  ConsentViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/27.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ResearchKit/ResearchKit.h"


@interface ConsentViewController : UIViewController <ORKTaskViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property ORKTaskViewController *taskViewController;
@property ORKConsentDocument *consent;
@property NSData *pdfFile;

@property UIAlertController* alert;
@property BOOL consentReviewHasBeenPresented;
-(void)sendPDFEmail; 
-(void)wantsPDFEmailed;
-(void)yesAction;
-(void)noAction;
-(void)pop;

@end
