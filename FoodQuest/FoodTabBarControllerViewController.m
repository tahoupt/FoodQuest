//
//  FoodTabBarControllerViewController.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/9/25.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "FoodTabBarControllerViewController.h"

@interface FoodTabBarControllerViewController ()

@end

@implementation FoodTabBarControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"tab bar preparing for segue");
}


@end
