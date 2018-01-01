//
//  AppDelegate.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/23.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "AppDelegate.h"
#import "Firebase.h"
#import "FQConstants.h"
#import "FQUtilities.h"
#import "SurveyViewController.h"
#import "SelectSurveyTableViewController.h"
#import "FQMainTableViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions; {

        
    return YES;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    
    
    // set initial view controller programmatically
    // to prevent storyboard initialization:
    // uncheck "is initial view controller" in storyboard attributes
    // in project info, clear values for:
    // 1) Info/Main storyboard file base name (usually "Main" for Main.storyboard)
    // 2) General/Deployment Info/Main Interface (usually "Main")
    
    // initialize window from Main.storyboard with the intro view controller,
    // and make it our root view controller
    // (hang onto _storyboard in an attempt to not reload survey controllers)
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    // NOTE: pushing a view in openURL (and getting proper popping back) only seems to work if rootViewControll is a NavigationController
//  UIViewController *introViewController = [_storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
    
//  self.window.rootViewController = introViewController;

    
     
    _menuNavigationController = [_storyboard instantiateViewControllerWithIdentifier:@"MenuNavigationController"];
    
    self.window.rootViewController = _menuNavigationController;


    _menuViewController = [_storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
    
    _surveyTableController = [_storyboard instantiateViewControllerWithIdentifier:@"SurveyTableViewController"];
    
    [self.window makeKeyAndVisible];
    
    // check if launching because of a custom url (otherwise launchURL stays nil)
    _launchURL = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];


   // [self launchSurveyWithID:@"panas" andShortID:@"12345"];

    return YES;
    
}

        
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options; {

    // respond to app being opened by a customURL
    // reject (return NO) if not called by an acceptable source application
    
    // this method called either:
    //
    // 1) in response to the app being opened by URL:
    // in which cause _launchURL has already been set, and it will be 
    // processed further when FQMainTableViewController viewDidLoad
    //
    // or
    //
    // 2) app was already running when url was received, 
    // (and so FQMainTableViewController already loaded), 
    // so we can handleURL right away
    
    
    // check if called by an acceptable source application
    if (   [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey]  isEqualToString:@"com.apple.mobilemail"]
        || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.MobileSMS"]
        || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilesafari"]

         || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilecal"]) {

        // launched from acceptable source application
                
        if ( nil == _launchURL) { // we were already running when url was received
            [self respondToURL: url];
        }
        return YES;

    }
    
    // TODO: put up alert that we don't accept communications from other apps
    
    // because from bad source app, set launchURL to nil so FQMainTableViewController won't process it...
  
    _launchURL = nil;

    return NO;
}

-(BOOL)respondToURL:(NSURL *)url; {

    // respond to the URL scheme ("<kSurveyURL>://?user=<userid>&survey=<surveyid>&id=<shortid>&confirm=<confirmationCode>")
    
    // called either by application:openURL:options (if app was already running) or by FQMainTableViewController viewDidLoad (if app was launched by the url)
    
    // handles 3 types of queries:
    // 1) user -- not currently implemented
    // 2) survey (with surveyID) and id (shortID to label sms batch that requested survey)
    // 3) confirm (with confirmation code sent by sms as part of onboarding to confirm joining the study)
    

    // clear launchURL, because we are about to process it
    
    if (url ==   _launchURL) { _launchURL = nil; }
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    NSDictionary *queries = [self queriesFromURL:url ];
    NSString *user_id = [queries objectForKey:@"user"];
    NSString *shortID = [queries objectForKey:@"id"];
    NSString *surveyID = [queries objectForKey:@"survey"];
    NSString *confirmation_code =  [queries objectForKey:@"confirm"];
    
        
    // TODO: validate user_id

    if (nil != user_id) {
        NSString *oldUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey ];
        
        if (nil != oldUserID) {
            if (![oldUserID isEqualToString:user_id]) {
                // NOTE: put up alert asking if we want to overwrite the oldUserID
                //       [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:kUserDefaultUserIDKey ];
                return NO;
            }
        }
    }
    
    if (nil != surveyID) {
    
        // check if already responded to survey
        if ([self alreadyTookSurvey: surveyID andShortID:shortID]) {
            return NO;
        }
    
    
        // launch the selected survey
        [self launchSurveyWithID:surveyID andShortID:shortID];
        return YES;
    }
    
    if (nil != confirmation_code) {
        // set the confirmation code as part of onboarding
        [self setConfirmationCode:confirmation_code];
        return YES;
    }
        
    // didn't recognize the queries, so do nothing...
    return NO;

}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder; {

// YES if the app’s state should be preserved or NO if it should not.

// You can add version information or any other contextual data to the provided coder object as needed. During restoration, you can use that information to help decide whether or not to proceed with restoring your app to its previous state.

    return YES;

}
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder; {

    // Asks the delegate whether the app’s saved state information should be restored.
    return YES;
}

-(NSDictionary *)queriesFromURL:(NSURL *)theURL; {

    NSURLComponents *components = [NSURLComponents componentsWithURL:theURL resolvingAgainstBaseURL:NO];
    
    NSArray *queryItems =[components queryItems];
    
        NSMutableDictionary *queries = [[NSMutableDictionary alloc] init];
    
    for (NSURLQueryItem *item in queryItems) {
        [queries setObject:item.value forKey: item.name];
    }
    
    return queries;

}


-(BOOL)alreadyTookSurvey:(NSString *)surveyID andShortID:(NSString *)shortID; {

    NSArray *priorSurveys = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPriorSurveysKey];
     
     if (nil != priorSurveys) {
         for (NSArray *survey in priorSurveys) {
             if ([surveyID isEqualToString:survey[0]] && [shortID isEqualToString:survey[1]]) {
             
                    UIAlertController *alert;

                    alert = [UIAlertController alertControllerWithTitle:@"Survey Already Completed"
                                                   message:@"You've already taken this aurvey! Thanks for your participation."
                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                   
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

                    [alert addAction:defaultAction];

                    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
                        
                    [navController presentViewController:alert animated:YES completion:nil];
                
                    return YES;
             
             } // surveyID and shortID matched
         } // next survey
     } // has prior surveys
    
    return NO;
}


-(void)launchSurveyWithID:(NSString *)surveyID andShortID:(NSString *)shortID; {

    
    // GOT TO WORK BY MAKING appdelegate window rootviewcontroller = menuNavigationController (and not introViewController), a
    // and then using [menuNavigationController pushViewController:_surveryViewController] to display survey
    

    // tried presenting _surveyTableVIewController and sending it a notification
    // to present desired survey -- didn't pop back properly
    // NSDictionary *userInfo = @{@"surveyID":surveyID};

    
    if (self.window.rootViewController != _menuNavigationController) {
    
        // want to see if we ever need to reset window.rootViewController
        // back to the _menuNavigationController...
        NSLog(@"ROOT VIEW CHANGED!");
    
    }



    // bind _mainTableController by explict setting of appdelegate.mainTableController 
    // in mainTableController didLoad

   if (surveyWithIDExists(surveyID)) {
    
        if (_mainTableController != nil) {
            [_mainTableController displaySurveyControllerForSurveyID:surveyID andShortID:shortID];
    
        }
        else {
            // TODO: post error if mainTableController has not been instantiated
        }

   } else {
    
         // TODO: post alert if survey is not recognized

    }
    
}



-(void)setConfirmationCode:(NSString *)code; {

     [[NSUserDefaults standardUserDefaults] setObject:code forKey:kUserConfirmationCodeKey];
     // check to see if confirmation code matches?
     
    UIAlertController *alert;

    if (YES) {
        alert = [UIAlertController alertControllerWithTitle:@"Confirmation received"
                                       message:@"Your enrollment has been confirmed. Thank you for joining  this study."
                                       preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"Confirmation mismatch"
                                       message:@"We don't recognize your confirmation code. Please try joining the study again."
                                       preferredStyle:UIAlertControllerStyleAlert];
    }

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:nil];

            
    [alert addAction:defaultAction];

    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
                
    [navController presentViewController:alert animated:YES completion:nil];
                

}

- (UIViewController *)topViewController{
  return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
// https://stackoverflow.com/questions/9009646/current-view-controller-from-appdelegate

  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }

  if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self topViewController:lastViewController];
  }

  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self topViewController:presentedViewController];
}

@end
