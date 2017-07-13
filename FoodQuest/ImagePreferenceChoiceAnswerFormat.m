//
//  ImagePreferenceChoiceAnswerFormat.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/5/3.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "ImagePreferenceChoiceAnswerFormat.h"
#import "ImagePreferenceChoice.h"

@implementation ImagePreferenceChoiceAnswerFormat


-(UIImage*) framedImageNamed:(NSString *) imageName;
{

    UIImage* bgImage = [UIImage imageNamed:imageName];
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
     UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height),3,3)];
    
    [path setLineWidth:6];
    [[UIColor blueColor] setStroke];
    [path stroke];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}


-(id)initWithImageIndex1:(NSInteger)index1 imageLabel1:(NSString *)label1 andImageIndex2:(NSInteger)index2 imageLabel2:(NSString *)label2 imageType:(NSString *)extension showImageLabels:(BOOL)showLabelFlag showNoPreferenceButton:(BOOL)noPrefFlag showAnswer:(BOOL)showAnswerFlag; {

    NSString *imageName1 = [NSString stringWithFormat:@"%ld.%@",(long)index1,extension];
    NSString *imageName2 = [NSString stringWithFormat:@"%ld.%@",(long)index2,extension];
    NSString *value1 =  [NSString stringWithFormat:@"%ld",(long)index1];
    NSString *value2 =  [NSString stringWithFormat:@"%ld",(long)index2];

    
    ImagePreferenceChoice *image1 = [ImagePreferenceChoice choiceWithNormalImage: [UIImage imageNamed:imageName1] selectedImage:[self framedImageNamed:imageName1] text:label1 value:value1];

    ImagePreferenceChoice *image2 =  [ImagePreferenceChoice choiceWithNormalImage: [UIImage imageNamed:imageName2] selectedImage: [self framedImageNamed:imageName2] text:label2 value:value2];
         
    self = [super  initWithImageChoices:@[image1,image2] ];
    
    if (self) {
        [self setAllowNoPreference:noPrefFlag];
        [self setShowSelectedAnswer:showAnswerFlag];
        [self setShowImageLabels:showLabelFlag];
        
        
     }

    return self;

}





@end
