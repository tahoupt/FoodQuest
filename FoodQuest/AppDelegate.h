//
//  AppDelegate.h
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectSurveyTableViewController;
@class SurveyViewController;
@class FQMainTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// bind _mainTableController by explict setting of appdelegate.mainTableController 
// in mainTableController didLoad
@property  (nonatomic, strong) IBOutlet FQMainTableViewController *mainTableController;

@property  (nonatomic, strong) IBOutlet SelectSurveyTableViewController *surveyTableController;


@property (strong, nonatomic) UIWindow *window;

@property UIStoryboard *storyboard;


@property  (strong, nonatomic) UINavigationController * menuNavigationController;

@property  (strong, nonatomic) UITableViewController * menuViewController;



@property  (strong, nonatomic) SurveyViewController *surveyViewController;


@property NSURL *launchURL;



-(BOOL)respondToURL:(NSURL *)url;
-(NSDictionary *)queriesFromURL:(NSURL *)theURL;
-(void)launchSurveyWithID:(NSString *)surveyID andShortID:(NSString *)shortID;
// check if surveyID/shortID tuple is stored in NSDefaults, indicating that we've already taken the survey
-(BOOL)alreadyTookSurvey:(NSString *)surveyID andShortID:(NSString *)shortID;
-(void)setConfirmationCode:(NSString *)code;

- (UIViewController *)topViewController;
- (UIViewController *)topViewController:(UIViewController *)rootViewController;


@end

