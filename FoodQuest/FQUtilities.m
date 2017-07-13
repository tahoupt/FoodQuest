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


