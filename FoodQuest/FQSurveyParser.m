//
//  FQSurveyParser.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/6/24.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "FQSurveyParser.h"
#import "FQUtilities.h"
#import "FQConstants.h"
#import "FQSurvey.h"

#import "ImagePreferenceChoiceAnswerFormat.h"
#import "ImageHedonicScaleAnswerFormat.h"

@implementation FQSurveyParser

-(id)initWithSurvey:(NSDictionary *)s;
 {

    self = [super init];
    if (self) {
    
   BOOL healthkitPermission = NO;
   
        _survey = s;
        
// get the number of images for use by image preference and rating scale questions
    _numberOfImages = 0;
    _images =  [_survey objectForKey:@"images" ];
    
    if  ( nil != _images && nil != [_images objectForKey:@"descriptions"]) {
        _numberOfImages = [[_images mutableArrayValueForKey:@"descriptions"]  count];
    }
        
        
        // initialize the dictionary that maps question types with answer construction blocks
        _answerConstructionBlocks = [NSMutableDictionary dictionary];
        
        _answerConstructionBlocks = @{ 
        
                 
 kFQSurveyMultipleChoiceType:
 
            ^ORKAnswerFormat *(NSDictionary *question) {
                
                NSMutableArray *answerChoices = [NSMutableArray array];
                for (NSDictionary *answer in [question objectForKey:@"answers"]) {
                    ORKTextChoice * choice = [ORKTextChoice choiceWithText:[answer objectForKey:@"text"] detailText:NULL value:[answer objectForKey:@"value"] exclusive:YES];
                    [answerChoices addObject:choice];
                }
                            
                return [[ORKTextChoiceAnswerFormat alloc] 
                                                                initWithStyle: ORKChoiceAnswerStyleMultipleChoice
                                                                textChoices: answerChoices];
                                                                
                                                                
            }, // kFQSurveyMultipleChoiceType

kFQSurveyDateOfBirthType:

            ^ORKAnswerFormat *(NSDictionary *question){
                if (healthkitPermission) {
                    return [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType: [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]];
                }
                else {
                    return [ORKAnswerFormat dateTimeAnswerFormat];
                }
            }, // kFQSurveyDateOfBirthType
            
            
kFQSurveyGenderType:

            ^ORKAnswerFormat *(NSDictionary *question) {
                if (healthkitPermission) {
                   return [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType: [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
                }
                else {
                    NSMutableArray *sexChoices = [NSMutableArray array];
                    ORKTextChoice * choice = [ORKTextChoice choiceWithText:@"female" detailText:NULL value:@"female" exclusive:YES];
                    [sexChoices addObject:choice];
                    choice = [ORKTextChoice choiceWithText:@"male" detailText:NULL value:@"male" exclusive:YES];
                    [sexChoices addObject:choice];

                    return [[ORKTextChoiceAnswerFormat alloc] 
                                    initWithStyle: ORKChoiceAnswerStyleMultipleChoice
                                    textChoices: sexChoices];
                }
            }, // kFQSurveyGenderType

kFQSurveyIntegerType:
            ^ORKAnswerFormat *(NSDictionary *question) {
                 return [[ORKNumericAnswerFormat alloc]initWithStyle:ORKNumericAnswerStyleInteger];
            } , // kFQSurveyIntegerType
            
kFQSurveyDecimalType:
            ^ORKAnswerFormat *(NSDictionary *question) {
                return [[ORKNumericAnswerFormat alloc]initWithStyle:ORKNumericAnswerStyleDecimal];
            }, // kFQSurveyDecimalType
            
kFQSurveyHeightType:
            ^ORKAnswerFormat *(NSDictionary *question) {
                return [ORKAnswerFormat heightAnswerFormat];
            }, // kFQSurveyHeightType
            
kFQSurveyWeightType:

            ^ORKAnswerFormat *(NSDictionary *question) {
            
                NSLocale *locale = [NSLocale currentLocale]; 
                BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
                if (isMetric) {
                    return [ORKAnswerFormat decimalAnswerFormatWithUnit:@"kg"];
                
                }
                return [ORKAnswerFormat integerAnswerFormatWithUnit:@"lbs"];
                

            }, // kFQSurveyWeightType
            
kFQSurveyBooleanType:
            ^ORKAnswerFormat *(NSDictionary *question) {
                return [ORKAnswerFormat booleanAnswerFormat];
            }, // kFQSurveyBooleanType

kFQSurveyImagePairType:

            ^ORKAnswerFormat *(NSDictionary *question) {
            
                    NSDictionary *answer = [[question objectForKey:@"answers" ] firstObject ];
                    NSInteger image1Index =  [[answer objectForKey:@"image_index"] integerValue];
                    NSString *image1Label =  [answer objectForKey:@"image_label"];
                    
                    NSDictionary *answer2 = [[question objectForKey:@"answers" ] objectAtIndex:1];
                    NSInteger image2Index =  [[answer2 objectForKey:@"image_index"] integerValue];
                    NSString *image2Label =  [answer2 objectForKey:@"image_label"];

                    BOOL show_image_labels = NO;
                    BOOL allow_no_preference = NO;
                    BOOL show_answer = NO;
                    if ([answer objectForKey:@"show_image_labels"]) {
                        show_image_labels = [[answer objectForKey:@"show_image_labels"] boolValue];
                    }
                   if ([answer objectForKey:@"allow_no_preference"]) {
                        allow_no_preference = [[answer objectForKey:@"allow_no_preference"] boolValue];
                    }
                   if ([answer objectForKey:@"show_answer"]) {
                        show_answer = [[answer objectForKey:@"show_answer"] boolValue];
                    }
                    
                return [[ImagePreferenceChoiceAnswerFormat alloc] 
                        initWithImageIndex1: image1Index
                        imageLabel1:image1Label
                        andImageIndex2: image2Index
                        imageLabel2:image2Label
                        imageType: [_images objectForKey:@"extension" ] 
                        showImageLabels: show_image_labels
                        showNoPreferenceButton:allow_no_preference 
                        showAnswer:show_answer]; 
            }, // kFQSurveyImagePairType

kFQSurveyRandomImagePairsType:
            ^ORKAnswerFormat *(NSDictionary *question) {
                return nil; // we'll add random questions below...
            },
kFQSurveyHedonicScaleType:
            ^ORKAnswerFormat *(NSDictionary *question) {
                    NSDictionary *answer = [[question objectForKey:@"answers" ] firstObject ];
                    NSInteger imageIndex =  [[answer objectForKey:@"image_index"] integerValue];
                    NSString *imageLabel =  [answer objectForKey:@"image_label"] ;
                    BOOL show_image_labels = NO;
                    BOOL allow_no_preference = NO;
                    BOOL show_answer = NO;
                    if ([answer objectForKey:@"show_image_labels"]) {
                        show_image_labels = [[answer objectForKey:@"show_image_labels"] boolValue];
                    }
                   if ([answer objectForKey:@"allow_no_preference"]) {
                        allow_no_preference = [[answer objectForKey:@"allow_no_preference"] boolValue];
                    }
                   if ([answer objectForKey:@"show_answer"]) {
                        show_answer = [[answer objectForKey:@"show_answer"] boolValue];
                    }

                    
                   if ([[question objectForKey:@"scale_type"] isEqualToString:kFQNatickSurveyScaleType]) {
                       return [[NatickImageScaleAnswerFormat alloc] 
                            initWithImageIndex:imageIndex 
                            imageType: [_images objectForKey:@"extension" ]  
                            imageLabel:imageLabel
                            showImageLabel: show_image_labels];
                    }
                    
                    // assume kFQLabeledMagnitudeSurveyScaleType by default
                    return [[LHSImageScaleAnswerFormat alloc] 
                            initWithImageIndex:imageIndex 
                            imageType: [_images objectForKey:@"extension" ]  
                            imageLabel:imageLabel
                            showImageLabel: show_image_labels];

                    

            }, // kFQSurveyHedonicScaleType
            
            
kFQSurveyRandomHedonicScaleType:
            ^ORKAnswerFormat *(NSDictionary *question) {
               return nil;
            } // kFQSurveyRandomHedonicScaleType
                        
            
            
        }.mutableCopy;
    
    }
    
    return self;

}

-(BOOL)recognizesKey:(NSString *)key; {

    return (nil !=[_answerConstructionBlocks objectForKey:key]);

}

-(void)addParserKey:(NSString *)key withAnswerBlock:(ORKAnswerFormat *(^)(NSDictionary *question)) block; {

    // TODO: error checking?
    [_answerConstructionBlocks setObject:block forKey:key];

}

-(void)removeBlockForParserKey:(NSString *)key; {

    // TODO: error checking?
    [_answerConstructionBlocks removeObjectForKey:key];

}



-(ORKAnswerFormat *)parseSurveyQuestion:(NSDictionary *)question; {

    if ([question objectForKey:@"type"] == nil ) {
                NSLog(@"null type");
                return nil;
    }
    
    if (![self recognizesKey:[question objectForKey:@"type"] ]) {
                NSLog(@"unrecognized type");
                return nil;
    }

   // ORKAnswerFormat *(^answerBlock)() = [_answerConstructionBlocks objectForKey:[question objectForKey:@"key"]];
    
    FQAnswerFormatBlock answerBlock = [_answerConstructionBlocks objectForKey:[question objectForKey:@"type"]];
    
    ORKAnswerFormat *answer = answerBlock(question);
    
    if (nil == answer) {
        NSLog(@"bad answer");
    }
    
    return answer;
}

@end
