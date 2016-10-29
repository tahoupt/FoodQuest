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


@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions; {

        // if launched using an URL scheme ("foodquest://?<userid>"), only launch if coming from safari or mail
        if (nil != [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        
            if (nil != [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey]) {
            
                if ([[launchOptions valueForKey:UIApplicationLaunchOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilemail"] || [[launchOptions valueForKey:UIApplicationLaunchOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilesafari"]) {

                    return YES;

                }
}
            else return NO;
        }
        
        return YES;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options; {

    // respond to the URL scheme ("foodquest://?<userid>"), and store the userid in UserDefaults
    
    // NOTE: check is we already have a userid in user defaults, but up warning if its going to change?
    
    // NOTE: include some checking of someother key (or structure of userid) 
    // to make sure its a valid userid and authentically sent by experimenter? 

    NSLog(@"Calling Application Bundle ID: %@", [options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey]);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
  
    // if launched using an URL scheme ("foodquest://?<userid>"), only launch if coming from safari or mail

    if ([[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilemail"] || [[options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.mobilesafari"]) {

        NSString *newUserID = [[url query] copy];
        
        // NOTE: validate newUserID

        NSString *oldUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserIDKey ];
        
        if (nil != oldUserID) {
            if (![oldUserID isEqualToString:newUserID]) {
            
                // NOTE: put up alert asking if we want to overwrite the oldUserID
                return NO;
            }
            else {
                return YES;
            }
        }

        [[NSUserDefaults standardUserDefaults] setObject:newUserID forKey:kUserDefaultUserIDKey ];

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






@end
