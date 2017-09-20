//
//  FQExternalStoryboardSegue.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/9/16.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "FQExternalStoryboardSegue.h"

@implementation FQExternalStoryboardSegue

//| ----------------------------------------------------------------------------
- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    // Load the storyboard named by this segue's identifier.
    UIStoryboard *externalStoryboard = [UIStoryboard storyboardWithName:identifier bundle:[NSBundle bundleForClass:self.class]];
    
    // Instantiate the storyboard's initial view controller.
    id initialViewController = [externalStoryboard instantiateInitialViewController];
    
    return [super initWithIdentifier:identifier source:source destination:initialViewController];
}


//| ----------------------------------------------------------------------------
- (void)perform
{
    [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:NULL];
}


@end
