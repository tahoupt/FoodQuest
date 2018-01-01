//
//  FQUtilities.h
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/15.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#ifndef FQUtilities_h
#define FQUtilities_h

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"

NSDictionary *surveyWithID(NSString *surveyID);
BOOL surveyWithIDExists(NSString *surveyID);
NSString *surveyPath(NSString *surveyID); // path of <surveyID>.yaml in bundle/surveys

NSMutableDictionary *FQTaskResultToDictionary(ORKTaskResult *taskResult, NSDictionary *survey);
void SaveResultToFirebase(NSDictionary *result_data);
void SaveSubjectToFirebase(void);
void WithdrawSubjectFromFirebase(void);


NSDictionary *QuestionFromIdentifier(NSString *key,NSDictionary *survey);

/** convert "THoupt@fsu.edu" to "thoupt_at_fsu.edu"
*/
NSString *UserIDFromEmail(NSString *email); 

@interface NSString(FQSurvey)
-(NSString *) stringValue;
@end



#endif /* FQUtilities_h */
