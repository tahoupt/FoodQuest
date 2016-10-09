//
//  LMSScaleLabel.h
//  ResearchKit
//
//  Created by Tom Houpt on 16/10/7.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKScaleRangeDescriptionLabel.h"

@interface LMSScaleLabel : ORKScaleRangeDescriptionLabel 
// ultimately descended from UILabel

@property CGFloat axisRelativePosition; // position on the axis of -100.0 (very bottom) to 100% (very top)

@end
