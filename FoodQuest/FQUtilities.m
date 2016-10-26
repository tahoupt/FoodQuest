//
//  FQUtilities.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/15.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "FQUtilities.h"

NSMutableDictionary *TaskResultToDictionary(ORKTaskResult *taskResult) {

    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    d[@"task_id"] = taskResult.identifier;
    d[@"start_time"] = [NSNumber numberWithDouble:[taskResult.startDate timeIntervalSince1970]];;
    d[@"end_time"] = [NSNumber numberWithDouble:[taskResult.endDate timeIntervalSince1970]];;

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    for (ORKStepResult *stepResult in taskResult.results) {
    
        NSMutableDictionary *sr = [NSMutableDictionary dictionary];
        double start_time = [stepResult.startDate timeIntervalSince1970]; 
        double end_time = [stepResult.endDate timeIntervalSince1970];
        double latency = end_time - start_time;
        
        sr[@"start_time"] = [NSNumber numberWithDouble:start_time];
        sr[@"latency"] = [NSNumber numberWithDouble:latency];
    
        if (0 < [stepResult.results count]) {
        
            // different parsing for preference choice result vs hedonic scale result
            
            // here we distinquish two types of results based on specific class of results[0]: ORKChoiceQuestionResult vs ORKScaleQuestionResult
            //  results[0] will be a ORKQuestionResult object, so could look at results[0].question type @"ORKQuestionTypeChoice" vs. @"ORKQuestionTypeScale"
        
            if ([stepResult.results[0] isKindOfClass:[ORKChoiceQuestionResult class]] ) {
                if (nil != ((ORKChoiceQuestionResult *)stepResult.results[0]).choiceAnswers[0]) {
                
                    sr[@"q_type"] = @"pref_choice";
                    sr[@"answer"] = ((ORKChoiceQuestionResult *)stepResult.results[0]).choiceAnswers[0];
                }
                
            }
            if ([stepResult.results[0] isKindOfClass:[ORKScaleQuestionResult class]] ) {
                if (nil != ((ORKScaleQuestionResult *)stepResult.results[0]).scaleAnswer) {
                        sr[@"q_type"] = @"hedonic_scale";
                        sr[@"answer"] = ((ORKScaleQuestionResult *)stepResult.results[0]).scaleAnswer;
                        // NOTE: need a way to capture which item is being rated; maybe add a NSString *_itemRated property to ORKScaleQuestionResult?
                        // sr[@"item_id"] = ((ORKScaleQuestionResult *)stepResult.results[0]).itemRated;
                        // or just make answer @"<item_id>=<rating>"

                }
            }
            
            
        } // > 0 results for this step
        
        results[stepResult.identifier] = sr;


    } // next step
    
    d[@"step_results"] = results;

    return d;

}

