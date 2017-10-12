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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property UIStoryboard *storyboard;


@property  (strong, nonatomic) UINavigationController * menuNavigationController;

@property  (strong, nonatomic) UITableViewController * menuViewController;
@property  (strong, nonatomic) SelectSurveyTableViewController * surveyTableController;

@property  (strong, nonatomic) SurveyViewController *surveyViewController;


-(NSDictionary *)queriesFromURL:(NSURL *)theURL;
-(void)launchSurveyWithID:(NSString *)surveyID andShortID:(NSString *)shortID;

@end

