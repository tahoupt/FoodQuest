//
//  SettingsViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/7/13.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property BOOL validUserID;
@property BOOL validEmail;
@property BOOL validPhoneNumber;

@property BOOL foundUserIDError;
@property BOOL foundEmailError;
@property BOOL foundPhoneNumberError;

// @property (weak, nonatomic) IBOutlet UITextField *userID; // tag 104
@property (weak, nonatomic) IBOutlet UITextField *email; // tag 103
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber; // tag 102

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

-(IBAction)validateEmailAddress:(id)sender;
-(IBAction)validatePhoneNumber:(id)sender;
// -(IBAction)validateUserID:(id)sender;
-(IBAction)continueButtonPressed:(id)sender;

- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string;

@end
