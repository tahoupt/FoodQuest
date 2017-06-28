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

NSMutableDictionary *FQTaskResultToDictionary(ORKTaskResult *taskResult);
void SaveResultToFirebase(NSDictionary *result_data);


@interface NSString(FQSurvey)
-(NSString *) stringValue;
@end



#endif /* FQUtilities_h */
