//
//  FQUtilities.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/15.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "FQUtilities.h"
#import "FQConstants.h"
#import "Firebase.h"
#import <YAML/YAMLSerialization.h>

@implementation NSString(FQSurvey)
  -(NSString *) stringValue {
  return self;
}
@end


NSDictionary *surveyWithID(NSString *surveyID){

    // TODO: add error check and return nil if an error
    
    NSString * surveysPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"surveys"];
    
    NSString *surveyName = [NSString stringWithFormat:@"%@.yaml", surveyID];
    
    NSString* path = [surveysPath stringByAppendingPathComponent:surveyName];
    
    NSString *yamlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

    NSError * error;

    NSMutableArray *yamlObjects = [YAMLSerialization
                                        objectsWithYAMLString: yamlString
                                        options:  kYAMLReadOptionStringScalars
                                        error: &error];
                                                    
                                                    
    return [yamlObjects firstObject];                                               
    


}




NSDictionary *QuestionFromIdentifier(NSString *key,NSDictionary *survey) {


    if (nil == survey ) { return nil; }
    
    NSArray *sections = [survey objectForKey:@"sections"];
    
    for (NSDictionary *section in sections) {
    
        NSDictionary *questions = [section objectForKey:@"questions"];
        
            for (NSDictionary *question in questions) {
            
                NSString *question_key = [question objectForKey:@"key"];
            
                if ([key isEqualToString:question_key]) {
                
                    return question;
                
                }
                
            
            }
    
    }
    
    return nil;


}



NSMutableDictionary *FQTaskResultToDictionary(ORKTaskResult *taskResult, NSDictionary *survey) {

    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey];
    
    // NOTE: for debugging purposes, assign temp id
    if (nil == userID) { userID = @"thoupt"; }
    d[@"user_id"] = userID;
    
    d[@"survey_key"] = taskResult.identifier;
    d[@"start_time"] = [[NSNumber numberWithDouble:[taskResult.startDate timeIntervalSince1970]] stringValue];
    d[@"end_time"] = [[NSNumber numberWithDouble:[taskResult.endDate timeIntervalSince1970]] stringValue];

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    for (ORKStepResult *stepResult in taskResult.results) {
    
        // only include those steps that were actually completed (i.e. don't include skipped questions)
        
            NSMutableDictionary *sr = [NSMutableDictionary dictionary];
            sr[@"key"] = stepResult.identifier;
            NSDictionary *question = QuestionFromIdentifier(stepResult.identifier,survey);
            
           if (nil != question) {  sr[@"type"] = [question objectForKey:@"type"]; }
            double start_time = [stepResult.startDate timeIntervalSince1970]; 
            double end_time = [stepResult.endDate timeIntervalSince1970];
            double latency = end_time - start_time;
            sr[@"start_time"] = [[NSNumber numberWithDouble:start_time] stringValue];
            sr[@"latency"] = [NSString stringWithFormat:@"%.3lf",latency];

        
            // different parsing for preference choice result vs hedonic scale result
            
            // here we distinquish two types of results based on specific class of results[0]: ORKChoiceQuestionResult vs ORKScaleQuestionResult
            //  results[0] will be a ORKQuestionResult object, so could look at results[0].question type @"ORKQuestionTypeChoice" vs. @"ORKQuestionTypeScale"
        
            // NOTE: subclass ORKChoiceQuestionResult to:
            // ORKImagePrefQuestionResult
            // ORKImageScaleQuestionResult
            // capture other types of results? text,date of birth, height, weight, sex
            
            sr[@"answer"] = @"**skipped**";

            
            if (0 < [stepResult.results count]) {


            if ([stepResult.results[0] isKindOfClass:[ORKBooleanQuestionResult class]] ) {

                 sr[@"answer"] =  [((ORKBooleanQuestionResult *)stepResult.results[0]).booleanAnswer boolValue] ? @"true" : @"false";
                 
            }
            else if ([stepResult.results[0] isKindOfClass:[ORKChoiceQuestionResult class]] ) {
                        if (0 < [((ORKChoiceQuestionResult *)stepResult.results[0]).choiceAnswers count]) {
                        
                            ORKChoiceQuestionResult *choiceResult =(ORKChoiceQuestionResult *)stepResult.results[0];
                        
                        
                            NSString *answer =  [choiceResult.choiceAnswers[0] stringValue];
                            
                            sr[@"answer"] = answer;
                            
                         //  sr[@"answer"] = [((ORKChoiceQuestionResult *)stepResult.results[0]).choiceAnswers[0] stringValue];
                        }
                        
            }
            else if ([stepResult.results[0] isKindOfClass:[ORKLocationQuestionResult class]] ) {

                sr[@"answer"] =  @"location"; // NOTE: TODO: need to complete this
            }
            else if ([stepResult.results[0] isKindOfClass:[ORKDateQuestionResult class]] ) {

                sr[@"answer"] =  [NSString stringWithFormat:@"%f",[((ORKDateQuestionResult *)stepResult.results[0]).dateAnswer timeIntervalSince1970]];

            }
            else if ([stepResult.results[0] isKindOfClass:[ORKNumericQuestionResult class]] ) {
                
                    NSString *unit = ((ORKNumericQuestionResult *)stepResult.results[0]).unit == nil ? @"" : ((ORKNumericQuestionResult *)stepResult.results[0]).unit ;
                    sr[@"answer"] =   [NSString stringWithFormat:@"%@ %@", [((ORKNumericQuestionResult *)stepResult.results[0]).numericAnswer  stringValue], unit  ];

            }
            else if ([stepResult.results[0] isKindOfClass:[ORKScaleQuestionResult class]] ) {

                        NSInteger imageIndex;
                        double imageRating;
                        double scaleValue = [((ORKScaleQuestionResult *)stepResult.results[0]).scaleAnswer doubleValue];
                        if (scaleValue < 0) {
                            imageIndex = floor(-1 * scaleValue / 1000.0);
                            imageRating = scaleValue + (imageIndex * 1000.0);
                        }
                        else {
                            imageIndex = floor(scaleValue / 1000.0);
                            imageRating = scaleValue - (imageIndex * 1000.0);                     
                        }
                        sr[@"answer"] = [NSString stringWithFormat:@"%ld=%lf", (long)imageIndex, imageRating ];
                        
            }
            else if ([stepResult.results[0] isKindOfClass:[ORKTextQuestionResult class]] ) {

                    sr[@"answer"] =  ((ORKTextQuestionResult *)stepResult.results[0]).textAnswer;

            }
            else if ([stepResult.results[0] isKindOfClass:[ORKTimeIntervalQuestionResult class]] ) {

                    sr[@"answer"] =  [((ORKTimeIntervalQuestionResult *)stepResult.results[0]).intervalAnswer stringValue];

            }
            else if ([stepResult.results[0] isKindOfClass:[ORKTimeOfDayQuestionResult class]] ) {

                    NSInteger hour = [((ORKTimeOfDayQuestionResult *)stepResult.results[0]).dateComponentsAnswer  hour];
                    NSInteger minute = [((ORKTimeOfDayQuestionResult *)stepResult.results[0]).dateComponentsAnswer  minute];

                    sr[@"answer"] =  [NSString stringWithFormat:@"%ld:%ld",(long)hour, (long)minute];

            }

        } // > 0 results for this step
        // if no results, then skipped (which is default value for sr[@"answer"]
       
            
        results[stepResult.identifier] = sr;

            
    } // next step
    
    
    d[@"step_results"] = results;

    NSLog(@"task dictionary: %@",d);

    return d;

}

void SaveResultToFirebase(NSDictionary *result_data) {

    // only save to database if we have recruitment userid
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultUserIDKey];
  
    // TODO: put up alert that they need to sign up to save results
    if (nil == userID) { userID = @"thoupt"; }

    if (nil != userID){
        
      FIRDatabaseReference *firebaseRef = [[FIRDatabase database] reference];
      
      // Push data to Firebase Database
      [[[[firebaseRef child:kFirebaseDirectory] child:@"results"] childByAutoId] setValue:result_data];

    }
  
}

void SaveSubjectToFirebase(void) {

    /* subject_data fields:
        userID : 
        first_name
        last_name
        consent_date : date string from consent form
        consent_date_format
        participating : Boolean if currently participating
        withdrawal_date : time stamp, only present if subject withdrew from study
        date_of_birth
        sex
        email
        phone
        device  derived from UIDevice call
            name
            systemName
            systemVersion
            model
            localizedModel
            identifierForVendor
        has_confirmed : time stamp for when user responded to confirmation email/text
        
    */
    
    NSMutableDictionary *subject_data = [NSMutableDictionary dictionary];

    // only save to database if we have recruitment userid
    // TODO: this might be replaced with a normalized version of email address?
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultUserIDKey];
    
    // date of birth and sex should have been stored in userdefaults during eligibility 
    subject_data[kUserDateOfBirthKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDateOfBirthKey];
    subject_data[kUserSexKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserSexKey];
    
    // names, email,  phone number, consent pdf link,  and consent date were saved when consent was given
    subject_data[kUserFirstNameKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserFirstNameKey];
    subject_data[kUserLastNameKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserLastNameKey];
    subject_data[kUserTitleKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserTitleKey];
    subject_data[kUserEmailKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserEmailKey];
    subject_data[kUserPhoneKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserPhoneKey];
    subject_data[kUserGaveConsentDateKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserGaveConsentDateKey];
    subject_data[kUserGaveConsentDateFormatKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserGaveConsentDateFormatKey];
    subject_data[kUserGaveConsentDateFormatKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserGaveConsentDateFormatKey];
    subject_data[kUserParticipatingFlagKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserParticipatingFlagKey];
   
    // maybe we withdrew?
    subject_data[kUserWithdrawalDateKey] = [[NSUserDefaults standardUserDefaults] objectForKey: kUserWithdrawalDateKey];    
    
    
    // get device info
    
    UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *device_data = [NSMutableDictionary dictionary];
    device_data[@"name"] = device.name;
    device_data[@"systemName"] = device.systemName;
    device_data[@"systemVersion"] = device.systemVersion;
    device_data[@"model"] = device.model;
    device_data[@"localizedModel"] = device.localizedModel;
    device_data[@"identifierForVendor"] = [device.identifierForVendor UUIDString];
    
    subject_data[@"device"] = device_data;
    
  
    if (nil == userID) { userID = @"thoupt2"; }
    
    

    if (nil != userID){
        
      FIRDatabaseReference *firebaseRef = [[FIRDatabase database] reference];
      
      // Push data to Firebase Database
      [[[[firebaseRef child:kFirebaseDirectory] child:@"subjects"] child:userID]  setValue:subject_data];

    }
  
}

NSString *UserIDFromEmail(NSString *email) {
    return [[email lowercaseString] stringByReplacingOccurrencesOfString:@"@" withString:@"_at_"];

}


