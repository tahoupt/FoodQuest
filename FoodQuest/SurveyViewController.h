//
//  SurveyViewController.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/8.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResearchKit/ResearchKit.h"
#import "SurveyTaskViewController.h"

@interface SurveyViewController : UIViewController <ORKTaskViewControllerDelegate>

@property NSDictionary *survey;
@property SurveyTaskViewController *taskViewController;
@property IBOutlet UIViewController *homeViewController;

@property HKHealthStore *healthStore;
@property NSInteger last24hStepCount;

- (NSSet *)dataTypesToWrite;
- (NSSet *)dataTypesToRead;

// flag so that survey is not presented again when taskViewCOntroller is dismissed (which triggers viewDidAppear again)
@property BOOL surveyHasBeenPresented;

-(void)pop;

-( NSMutableDictionary *)getHealthKitData;

- (void)fetchHKQuantityWithIdentifier:(NSString *)identifier andKey:(NSString *)key forInterval:(double)interval completion:(void (^)(NSString *,NSString *,double,NSError *))completionHandler;

@end
