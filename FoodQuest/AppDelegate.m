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

    return YES;
    
}

        
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options; {

    // respond to the URL scheme ("<kSurveyURL>://?user=<userid>&survey=<surveyid>"), and store the userid in UserDefaults
    
    // NOTE: check if we already have a userid in user defaults, but up warning if its going to change?
    
    // NOTE: include some checking of someother key (or structure of userid) 
    // to make sure its a valid userid and authentically sent by experimenter? 

    NSLog(@"Calling Application Bundle ID: %@", [options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey]);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    NSDictionary *queries = [self queriesFromURL:url ];
    
    NSString *newUserID = [queries objectForKey:@"user"];
    NSString *surveyID = [queries objectForKey:@"survey"];
      
    // if launched using an URL scheme ("<kSurveyURL>://?user=<userid>&survey=<surveyid>"), 
    // only launch if coming from sms or mail (or safari or ical for testing)
    // see http://labs.wrprojects.com/apple-ios-9-3-native-app-bundle-identifiers/
    
    if (    
        [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey]  isEqualToString:@"com.apple.mobilemail"]
        || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.MobileSMS"]
        || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilesafari"]

         || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilecal"]) {

        
        // NOTE: validate newUserID

        NSString *oldUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey ];
        
        if (nil != oldUserID) {
            if (![oldUserID isEqualToString:newUserID]) {
                // NOTE: put up alert asking if we want to overwrite the oldUserID
                //       [[NSUserDefaults standardUserDefaults] setObject:newUserID forKey:kUserDefaultUserIDKey ];
                return NO;
            }
        }
        
        if (nil != surveyID) {
            // launch the selected survey
            [self launchSurveyWithID:surveyID];
        }
        
        return YES;

    }
    else {
        
        // TODO: put up alert that we don't accept communications from other apps
    
    }
  
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


-(NSDictionary *)queriesFromURL:(NSURL *)theURL; {

    NSURLComponents *components = [NSURLComponents componentsWithURL:theURL resolvingAgainstBaseURL:NO];
    
    NSArray *queryItems =[components queryItems];
    
        NSMutableDictionary *queries = [[NSMutableDictionary alloc] init];
    
    for (NSURLQueryItem *item in queryItems) {
        [queries setObject:item.value forKey: item.name];
    }
    
    return queries;

}


-(void)launchSurveyWithID:(NSString *)surveyID; {

    
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

    

    NSDictionary *survey = surveyWithID(surveyID);
    
    if (nil == survey) {
    
         // TODO: post alert if survey is not recognized

    }
    else {
    

        // TODO: how to check if already in the middle of a survey?

   // https://stackoverflow.com/questions/24939465/dismiss-modal-then-immediately-push-view-controller
    
        _surveyViewController = [_storyboard instantiateViewControllerWithIdentifier:@"SurveyViewController"];
    
        [_surveyViewController setSurvey: survey];
         
         // as in LaunchMe sample code
         UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
                
         [navController pushViewController:_surveyViewController animated:NO];
     
     }
 
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
