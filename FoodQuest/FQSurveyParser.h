//
//  FQSurveyParser.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/6/24.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit/ResearchKit.h"
#import "FQSurvey.h"


typedef  __kindof ORKAnswerFormat *(^FQAnswerFormatBlock)(NSDictionary *question);


@interface FQSurveyParser : NSObject

-(id)initWithSurvey:(NSDictionary *)survey;
-(BOOL)recognizesKey:(NSString *)key;

-(ORKAnswerFormat *)parseSurveyQuestion:(NSDictionary *)question;

-(void)addParserKey:(NSString *)key withAnswerBlock:(ORKAnswerFormat *(^)(NSDictionary *question)) block;
-(void)removeBlockForParserKey:(NSString *)key;

@property __weak NSDictionary *survey;
@property NSMutableDictionary *answerConstructionBlocks;

// for use by image preference and rating scale questions
@property NSDictionary *images;
@property NSUInteger numberOfImages;

@end
