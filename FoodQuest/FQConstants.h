//
//  FQConstants.h
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/15.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#ifndef FQConstants_h
#define FQConstants_h


#define kFirebaseDirectory @"FoodSurve"
#define kAppIdentifier @"FoodSurvé"
#define kStudyTitle @"Food Survey"
#define kStudyShortTitle @"FoodSurvey"
#define kSurveyURL @"foodsurve"


// user default keys
#define kUserDefaultUserIDKey @"user_id"
#define kUserConfirmationCodeKey @"confirmation_code"
#define kUserDateOfBirthKey @"date_of_birth"
#define kUserSexKey @"sex"
#define kUserEmailKey @"email"
#define kUserPhoneKey @"phone"
#define kUserFirstNameKey @"first_name"
#define kUserLastNameKey @"last_name"
#define kUserTitleKey @"title"
#define kUserMeetsCriteriaKey @"meets_criteria"
#define kUserGaveConsentDateKey @"consent_date"
#define kUserGaveConsentDateFormatKey @"consent_date_format"
#define kUserConsentPDFLinkKey @"consent_link"
#define kUserWithdrawalDateKey @"withdrawal_date"
#define kUserParticipatingFlagKey @"participating"
#define kUserPriorSurveysKey @"priorSurveys" // an array of [<surveyID>,<shortID>, <timestamp>] arrays, to record surveys already taken...


// Overview: definitions for consent section summaries
// each consent section will be displayed with a title and summary sentence;
// clicking on the "Learn more" link will bring up the given html file
// (which should be of type ".html" in the app's bundle)

#define kConsentStepTitle @"Welcome to FoodSurvé"

#define kOverviewTitle @"Overview"
#define kOverviewSummary @"Welcome to FoodSurvé"
#define kOverviewHTMLFile @"overview_content"

#define kDataGatheringTitle  @"Data Gathering"
#define kDataGatheringSummary @"The summary about the section goes here ..."
#define kDataGatheringHTMLFile @"datagathering_content" 

#define kPrivacyTitle  @"Privacy"
#define kPrivacySummary @"The summary about the section goes here ..."
#define kPrivacyHTMLFile @"privacy_content" 

#define kDataUseTitle @"Data Use"
#define kDataUseSummary @"The summary about the section goes here ..."
#define kDataUseHTMLFile @"dataUse_content"

#define kTimeTitle @"Time Commitment"
#define kTimeSummary @"The summary about the section goes here ..."
#define kTimeHTMLFile @"time_content" 

#define kSurveyTitle  @"Surveys"
#define kSurveySummary @"The summary about the section goes here ..."
#define kSurveyHTMLFile @"survey_content"

#define kTaskTitle @"Tasks"
#define kTaskSummary @"The summary about the section goes here ..."
#define kTaskHTMLFile @"tasks_content"

#define kWithdrawalTitle @"Withdrawing"
#define kWithdrawalSummary @"The summary about the section goes here ..."
#define kWithdrawalHTMLFile @"withdrawal_content"



#endif /* FQConstants_h */
