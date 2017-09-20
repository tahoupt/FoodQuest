//
//  SettingsViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/7/13.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "SettingsViewController.h"
#import "FQConstants.h"
#import "FQUtilities.h"

// TODO: put up confirmation that user wants to change values in database?

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // https://stackoverflow.com/questions/7794959/how-to-resign-first-responder-from-text-field-when-user-tap-elsewhere
    // TODO: make this an extension to UIViewController
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    // NOTE: deprecating userid, so make it always valid
    _validUserID = YES;
    _validEmail = NO;
    _validPhoneNumber = NO;
    
    _foundUserIDError= NO;
    _foundEmailError= NO;
    _foundPhoneNumberError= NO;
  
   
    
    NSString *storedPhoneNumber =   [[NSUserDefaults standardUserDefaults] objectForKey:kUserPhoneKey ];
    if (nil != storedPhoneNumber) {
        storedPhoneNumber = [self formatPhoneNumber:storedPhoneNumber deleteLastChar:NO];
        _phoneNumber.text = storedPhoneNumber;
    }
   
    NSString *storedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:kUserEmailKey ];
    if (nil != storedEmail) {
        _email.text = storedEmail;    
    }
 
    
    
}
-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
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



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {

    NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];

    // if it's the phone number textfield format it.
    if (textField.tag==102 ) {
        if (range.length == 1) {
            // Delete button was hit.. so tell the method to delete the last char.
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO ];
        }
        // validate the phone number, but only if it was previously found to be invalid
        // this way the initial entry incomplete entry is not flagged
        // until user moves to different textfield
        if (_foundPhoneNumberError) {
                [self validatePhoneNumber:self];
        }
        return NO;
    }
    
    else if (textField.tag == 103 && _foundEmailError) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self validateEmailAddress:self];
        return NO;
    }
    
//    else if (textField.tag == 104 && _foundUserIDError) {
//        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        [self validateUserID:self];
//        return NO; 
//
//    }

    return YES; 
}
// format phone number as typed in
// phone number field should have textField.tag==102, and we should be delegate of the textfield
// https://stackoverflow.com/questions/1246439/uitextfield-for-phone-number
-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {

    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers 
    NSError *error = NULL;
     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
     simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];

    // check if the number is to long
    if(simpleNumber.length>10) {
        // remove last extra chars.
        simpleNumber = [simpleNumber substringToIndex:10];
    }

    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }

    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length<7)
    simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];

    else   // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}


-(IBAction)validateEmailAddress:(id)sender; {

    //TODO: check if different from NSUserDefault
    // if yes, then it has changed...
    // and set an editedFlag so we will enable continue button
    
    /* based on chromium/blink
    https://github.com/ChromiumWebApps/blink/blob/ea798590bf47f65436cd9d0803b3d7af4d5d614f/Source/core/html/forms/EmailInputType.cpp
    static const char emailPattern[] =
            "[a-z0-9!#$%&'*+/=?^_`{|}~.-]+" // local part
            "@"
            "[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?" // domain part

    */
     if ( 0 == [_email.text length]) {
         [_email setTextColor:[UIColor blackColor]];
         _validEmail = NO;
     }
     else {
         
        NSString *emailPattern = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?";

        NSRange range = [_email.text rangeOfString:emailPattern options:NSRegularExpressionSearch];
        
        if (NSNotFound == range.location ) {
            NSLog(@"email not validated");
            [_email setTextColor:[UIColor redColor]];
            _validEmail = NO;
            _foundEmailError = YES;

        }
        else {
            [_email setTextColor:[UIColor blackColor]];
            _validEmail = YES;
        }
    }
    [self enableContinueButton];

}

-(IBAction)validatePhoneNumber:(id)sender; {


     if ( 0 == [_phoneNumber.text length]) {
         [_phoneNumber setTextColor:[UIColor blackColor]];
        _validPhoneNumber = NO;
     }
     else {
     
        NSString *phonePattern = @"\\([0-9]{3}\\) [0-9]{3}\\-[0-9]{4}";

        NSRange range = [_phoneNumber.text rangeOfString:phonePattern options:NSRegularExpressionSearch];
        
        if (NSNotFound == range.location ) {
            // TODO: put up error that email doesn't validate
            NSLog(@"phone not validated");
            [_phoneNumber setTextColor:[UIColor redColor]];
            _validPhoneNumber = NO;
            _foundPhoneNumberError = YES;
        }
        else {
            [_phoneNumber setTextColor:[UIColor blackColor]];
            _validPhoneNumber = YES;
        }

    }
    [self enableContinueButton];

    

}

//-(IBAction)validateUserID:(id)sender; {
//
//     if ( 0 == [_userID.text length]) {
//         [_userID setTextColor:[UIColor blackColor]];
//        _validUserID = NO;
//     }
//     else {
//        if (3 >= [_userID.text length]) {
//            NSLog(@"userID not validated -- too short");
//            [_userID setTextColor:[UIColor redColor]];
//            _validUserID = NO;
//            _foundUserIDError = YES;
//
//        }
//        else {
//            [_userID setTextColor:[UIColor blackColor]];
//            _validUserID = YES;
//        }
//    }
//    
//    [self enableContinueButton];
//
//}

-(void)enableContinueButton; {

    if (_validEmail && 
        _validPhoneNumber &&
        _validUserID) {
    
        _continueButton.enabled = YES;
    }
    else {
        _continueButton.enabled = NO;
    }
    
}
    

-(IBAction)continueButtonPressed:(id)sender; {

    [[self view] endEditing:YES];
    // make sure userid, email, and phone number were entered
    // forward on to consent documents...
   // [[NSUserDefaults standardUserDefaults] setObject:_userID.text forKey:kUserDefaultUserIDKey ];
    [[NSUserDefaults standardUserDefaults] setObject:_phoneNumber.text forKey:kUserPhoneKey ];
    [[NSUserDefaults standardUserDefaults] setObject:_email.text forKey:kUserEmailKey ];
    
    // use email as userID?
    [[NSUserDefaults standardUserDefaults] setObject:UserIDFromEmail(_email.text) forKey:kUserDefaultUserIDKey ];

        

}




@end
