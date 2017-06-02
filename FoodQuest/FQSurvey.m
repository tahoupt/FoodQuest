//
//  FQSurvey.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/3/10.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "FQSurvey.h"
#import <YAML/YAMLSerialization.h>


@implementation FQSurvey

-(id)initWithYaml:(NSString *)yamlString; {

    self = [super init];
    
    if (self) {
        NSError *error;
        NSMutableArray *yamlObjects = [YAMLSerialization
                                            objectsWithYAMLString: yamlString
                                            options:  kYAMLReadOptionStringScalars
                                            error: &error];
                                            
                                            
       NSLog(@"Yaml: %@", [yamlObjects description]);
    }
    
    return self;
                             
}        
@end
