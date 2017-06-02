//
//  ImageHedonicScaleAnswerFormat.h
//  FoodQuest
//
//  Created by Tom Houpt on 17/5/24.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//


#import <ResearchKit/ResearchKit.h>



/*
  see ORKScaleSliderView.m in ResearchKit for modifications to display image scale slider choice
*/

/** ImageHedonicScaleAnswerFormat

    subclass of ORKContinuousScaleAnswerFormat, to allow passing in of image info, and an array of scale tick values and their text labels. This info will be used in our re-write of ORKScaleSliderView, to display an image next to a vertical scale slider.


*/
@interface ImageHedonicScaleAnswerFormat : ORKContinuousScaleAnswerFormat

@property NSInteger imageIndex;
@property NSString *imageType;
@property NSString *imageLabel;
@property NSArray *scaleLabels;
@property NSArray *scaleValues;

@property BOOL showImageLabel;

/** initialize a new ImageHedonicScaleAnswerFormat with the given image and arrays of scale tick values and the associated tick labels
    

*/
-(id)initWithImageIndex:(NSInteger)imageIndex imageType:(NSString *)extension imageLabel:(NSString *)imageLabel scaleLabels:(NSArray *)labels scaleValues:(NSArray *)values showImageLabel:(BOOL)showLabel;
@end

/** subclass of ImageHedonicScaleAnswerFormat pre-populated to display an image scale with a rating scale based on a labeled magnitude hedonic scale

    ref: J. Lim, A. Wood, B. Green, Derivation and evaluation of a labeled hedonic scale., Chem. Senses. 34 (2009)..


*/
@interface LHSImageScaleAnswerFormat : ImageHedonicScaleAnswerFormat 

-(id)initWithImageIndex:(NSInteger)imageIndex imageType:(NSString *)extension imageLabel:(NSString *)imageLabel showImageLabel:(BOOL)showLabel;

@end

/** subclass of ImageHedonicScaleAnswerFormat  pre-populated  to display an image with a rating scale based on the Natick 9-point hedonic scale 

    ref: L. Jones, D. Peryam, L. Thurstone, Development of a scale for measuring soldiers' food preferences., Food Res. 20 (1955).


*/

@interface NatickImageScaleAnswerFormat : ImageHedonicScaleAnswerFormat 

-(id)initWithImageIndex:(NSInteger)imageIndex imageType:(NSString *)extension imageLabel:(NSString *)imageLabel showImageLabel:(BOOL)showLabel;

@end
