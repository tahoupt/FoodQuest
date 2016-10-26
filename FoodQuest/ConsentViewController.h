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

@property ORKConsentDocument *consent;
@property NSData *pdfFile;

-(void)sendPDFEmail; 
-(void)yesAction;

@end
