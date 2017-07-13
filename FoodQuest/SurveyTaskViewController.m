//
//  SurveyTaskViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/4/6.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "SurveyTaskViewController.h"

@interface SurveyTaskViewController ()

@end

@implementation SurveyTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)stepViewControllerWillAppear:(ORKStepViewController *)stepViewController; {

  //  NSLog(@"step will appear");
    
   // ORKStepHeaderView *headerView = [stepViewController headerView];
   // ORKHeadlineLabel *captionLabel = [headerView captionLabel]; // subclass of ORKLabel
   
   
   
   
   
   
}

/*   
    [self swizzleClassMethod:@selector(systemFontOfSize:) withReplacement:@selector(wb_systemFontOfSize:)];
    [self swizzleClassMethod:@selector(boldSystemFontOfSize:) withReplacement:@selector(wb_boldSystemFontOfSize:)];
    [self swizzleClassMethod:@selector(italicSystemFontOfSize:) withReplacement:@selector(wb_italicSystemFontOfSize:)];
    [self swizzleClassMethod:@selector(systemFontOfSize:weight:) withReplacement:@selector(wb_systemFontOfSize:weight:)];
    
}

void SwizzleClassMethod(Class c, SEL orig, SEL new) {

    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);

    c = object_getClass((id)c);

    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

+ (UIFont *)wb_systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight {
    return [self wb_fontOfSize:fontSize weight:weight];
}

+ (UIFont *)wb_systemFontOfSize:(CGFloat)fontSize; {
    UIFont *originalFont = [self wb_systemFontOfSize:fontSize];
    UIFont *font = [UIFont wb_regular];
    return [font fontWithSize:originalFont.pointSize];
}

+ (UIFont *)wb_boldSystemFontOfSize:(CGFloat)fontSize; {
    UIFont *originalFont = [self wb_boldSystemFontOfSize:fontSize];
    UIFont *font = [UIFont wb_bold];
    return [font fontWithSize:originalFont.pointSize];
}

+ (UIFont *)wb_italicSystemFontOfSize:(CGFloat)fontSize; {
    UIFont *originalFont = [self wb_italicSystemFontOfSize:fontSize];
    UIFont *font = [UIFont wb_italic];
    return [font fontWithSize:originalFont.pointSize];
}

*/

@end
