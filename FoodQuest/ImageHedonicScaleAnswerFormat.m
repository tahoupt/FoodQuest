//
//  ImageHedonicScaleAnswerFormat.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/5/24.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "ImageHedonicScaleAnswerFormat.h"

@implementation ImageHedonicScaleAnswerFormat

-(id)initWithImageIndex:(NSInteger)imageIndex imageType:(NSString *)extension  imageLabel:(NSString *)imageLabel scaleLabels:(NSArray *)labels scaleValues:(NSArray *)values showImageLabel:(BOOL)showLabel; {

    self = [super initWithMaximumValue:100 minimumValue:-100 defaultValue:0 maximumFractionDigits:0 vertical:YES maximumValueDescription:@"Top" minimumValueDescription:@"Bottom"];;

    if (self) {
    
        self.imageIndex = imageIndex;
        self.imageType = extension;
        self.imageLabel = imageLabel;
        self.scaleLabels = labels;
        self.scaleValues = values;
        
        self.showImageLabel = showLabel;
    
    }

    

    return self;

}

@end

@implementation LHSImageScaleAnswerFormat

-(id)initWithImageIndex:(NSInteger)imageIndex imageType:(NSString *)extension imageLabel:(NSString *)imageLabel showImageLabel:(BOOL)showLabel; {

        NSArray *labels = @[
        
            @"Most Liked Imaginable",
            @"Like Extremely",
            @"Like Very Much",
            @"Like Moderately",
            @"Like Slightly",
            @"Dislike Slightly",
            @"Dislike Moderately",
            @"Dislike Very Much",
            @"Dislike Extremely",
            @"Most Disliked Imaginable"

        ];


        NSArray *values = @[
            @100.00,
            @65.72,
            @44.43,
            @17.82,
            @6.25,
            @-5.92,
            @-17.59,
            @-41.58,
            @-62.89,
            @-100.00
        ];


    return [super initWithImageIndex:imageIndex imageType:extension imageLabel:imageLabel scaleLabels:labels scaleValues:values
        showImageLabel:showLabel];
    

}



@end

@implementation NatickImageScaleAnswerFormat

-(id)initWithImageIndex:(NSInteger)imageIndex imageType:(NSString *)extension imageLabel:(NSString *)imageLabel showImageLabel:(BOOL)showLabel; {

        NSArray *labels = @[
        
                @"Like Extremely",
                @"Like Very Much",
                @"Like Moderately",
                @"Like Slightly",
                @"Neither Like nor Dislike",
                @"Dislike Slightly",
                @"Dislike Moderately",
                @"Dislike Very Much",
                @"Dislike Extremely"
        
        ];
        
        NSArray *values = @[
            @100.00,
            @75.00,
            @50.00,
            @25.00,
            @0,
            @-25.00,
            @-50.00,
            @-75.00,
            @-100.00
        ];



    return [super initWithImageIndex:imageIndex imageType:extension imageLabel:imageLabel scaleLabels:labels scaleValues:values showImageLabel:showLabel];
    

}

-(NSNumber *)normalizedValueForNumber:(NSNumber *)value; {

    double v = [value doubleValue];
    
    NSInteger r = round((v + 100.0) * 9.0 / 200.0);
    
    return [NSNumber numberWithInteger:r];

}

@end
