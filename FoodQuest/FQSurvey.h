//
//  FQSurvey.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/10.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit/ResearchKit.h"

// yaml survey question-answer types


// HealthKit
#define kFQSurveyGenderType @"gender"
#define kFQSurveyHeightType @"height"
#define kFQSurveyWeightType @"weight"
#define kFQSurveyDateOfBirthType @"date_of_birth"

// these are not really questions, but we can include them in survey results...
#define kFQSurveyDietaryCaloriesType @"dietary_calorie_energy"
#define kFQSurveyActiveEnergyType @"active_energy_burn"
#define kFQSurveyBasalEnergyType @"basal_energy_burn"
#define kFQSurveyStepCountType @"step_count"


// image preference specific
#define kFQSurveyImagePairType @"image_pair"
#define kFQSurveyRandomImagePairsType @"random_image_pairs"
#define kFQSurveyHedonicScaleType @"hedonic_rating"
#define kFQSurveyRandomHedonicScaleType @"random_hedonic_rating"

// generic
#define kFQSurveyMultipleChoiceType @"multiple_choice" // TextChoice with single answer
#define kFQSurveyMultipleChoiceMultipleAnswersType @"multiple_choice_multiple" // TextChoice with multiple answer

#define kFQSurveyBooleanType @"boolean"
#define kFQSurveyIntegerType @"integer"
#define kFQSurveyDecimalType @"decimal"

// other researchkit types
#define kFQSurveyTimeOfDayType @"time_of_day"
#define kFQSurveyLocationType @"location"
#define kFQSurveyTimeIntervalType @"time_interval"
#define kFQSurveyValueType @"value"
#define kFQSurveyScaleType @"scale"
#define kFQSurveyContinuousScaleType @"continuous_scale"
#define kFQSurveyEmailType @"email"
#define kFQSurveyImageChoiceType @"image_choice"
#define kFQSurveyTextScaleType @"text_scale"
#define kFQSurveyValuePickerType @"value_picker"
#define kFQSurveyInstructionType @"instruction"
    // expects "instructions" value; uses stem as title

/* ORKAnswerFormats: 
ORKBooleanAnswerFormat
ORKContinuousScaleAnswerFormat
ORKDateAnswerFormat
ORKEmailAnswerFormat
ORKHealthKitCharacteristicTypeAnswerFormat
ORKHealthKitQuantityTypeAnswerFormat
ORKImageChoiceAnswerFormat
ORKLocationAnswerFormat
ORKNumericAnswerFormat
ORKScaleAnswerFormat
ORKTextAnswerFormat
ORKConfirmTextAnswerFormat
ORKTextChoiceAnswerFormat
ORKTextScaleAnswerFormat
ORKTimeIntervalAnswerFormat
ORKTimeOfDayAnswerFormat
ORKValuePickerAnswerFormat
*/



#define kFQLabeledMagnitudeSurveyScaleType @"lms"
#define kFQNatickSurveyScaleType @"natick"


#define kWeightUnits @"lbs"

@interface FQSurveyQuestion: NSObject 

    @property NSString *key;
    @property NSString *stem;
    @property NSString *type; // dob, gender, height, weight, multiple choice, boolean
    @property NSArray<ORKTextChoice*> *answers; // if multiple choice
    // [ORKTextChoice choiceWithText:detailText:value:exclusive:]

@end


@interface FQSurveySection : NSObject

@property NSString *title;
@property NSString *key;
@property NSArray<FQSurveyQuestion*> *questions;


@end

@interface FQSurvey : NSObject


@property NSString *title;
@property NSString *identifier;
@property NSString *instructions;
@property NSString *comment;
@property NSString *reference;
@property NSString *permissions;
@property NSString *revision_history;
@property NSArray<FQSurveySection*> *sections;


-(id)initWithYaml:(NSString *)yamlString;


@end
