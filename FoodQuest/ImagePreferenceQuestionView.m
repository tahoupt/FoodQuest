//
//  ImagePreferenceQuestionView.m
//  FoodQuest
//
//  Created by Tom Houpt on 17/5/3.
//  Copyright © 2017 Behavioral Cybernetics. All rights reserved.
//

#import "ImagePreferenceQuestionView.h"
#import "ImagePreferenceChoiceAnswerFormat.h"






/*

Behavioral Cybernetics 2016 T. Houpt
Heavily modified ORKImageSelectionView to allow forced 2 choice preference test...


*/

// ORKImageChoiceLabel -> UILabel
//#import "/Users/houpt/Programming_Github/ResearchKit/ResearchKit/Common/ORKImageChoiceLabel.h"
//
//#import "/Users/houpt/Programming_Github/ResearchKit/ResearchKit/Common/ORKChoiceAnswerFormatHelper.h"
//
//#import "/Users/houpt/Programming_Github/ResearchKit/ResearchKit/Common/ORKHelpers_Internal.h"
//#import "ORKSkin.h"


@interface ORKChoiceButtonView : UIView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *labelText;

@end


@implementation ORKChoiceButtonView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice {
    self = [super init];
    if (self) {
        _labelText = choice.text.length > 0 ? choice.text: @" ";
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.exclusiveTouch = YES;
       
        if (choice.selectedStateImage) {
            [_button setImage:choice.selectedStateImage forState:UIControlStateSelected];
        }
        
        [_button setImage:choice.normalStateImage forState:UIControlStateNormal];
        
        _button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_button];
        
               
        
        
        
      //-->  ORKEnableAutoLayoutForViews(@[_button, _button.imageView]);
        [self setUpConstraints];
        
        // Accessibility
        NSString *trimmedText = [self.labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( trimmedText.length == 0 ) {
           //--> self.button.accessibilityLabel = ORKLocalizedString(@"AX_UNLABELED_IMAGE", nil);
        } else {
            self.button.accessibilityLabel = self.labelText;
        }
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{ @"button": _button };
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    UIImage *image = [_button imageForState:UIControlStateNormal];
    if (image.size.height > 0 && image.size.width > 0) {
        // Keep Aspect ratio
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button.imageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:image.size.height / image.size.width
                                                             constant:0.0]];
        // button's height <= image
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:nil attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:image.size.height]];
    } else {
        // Keep Aspect ratio
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button.imageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:0.0]];
      //-->  ORK_Log_Warning(@"The size of imageChoice's normal image should not be zero. %@", image);
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end


static const CGFloat SpacerWidth = 10.0;

 @implementation ImagePreferenceQuestionView
 {
   //--> ORKChoiceAnswerFormatHelper *_helper;
    NSArray *_buttonViews;
   UILabel *_choiceLabel;
   UILabel *_placeHolderLabel;
    UIButton *_noPrefButton;
    UILabel *_noPrefLabel;
}

- (UILabel *)makeLabel {
    UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
  //-->  label.numberOfLines = 0;
    return label;
}

- (instancetype)initWithImageChoiceAnswerFormat:(ORKImageChoiceAnswerFormat *)answerFormat answer:(id)answer {
    self = [self init];
    if (self) {
        
        NSAssert([answerFormat isKindOfClass:[ORKImageChoiceAnswerFormat class]], @"answerFormat should be an instance of ORKImageChoiceAnswerFormat");
        
       //--> _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        _placeHolderLabel = [self makeLabel];
        //-->  _placeHolderLabel.text = [ORKLocalizedString(@"PLACEHOLDER_IMAGE_CHOICES", nil) stringByAppendingString:@""];
        _placeHolderLabel.textColor = [UIColor grayColor];
        
        _choiceLabel = [self makeLabel];
        
        [self resetLabelText];
        
        [self addSubview:_choiceLabel];
        [self addSubview:_placeHolderLabel];
        
        NSMutableArray *buttonViews = [NSMutableArray new];
        NSMutableArray *labelTextArray = [NSMutableArray new];
        
        NSArray *imageChoices = answerFormat.imageChoices;
        for (ORKImageChoice *imageChoice in imageChoices) {
            if (imageChoice.text) {
                [labelTextArray addObject:imageChoice.text];
            }
            
            ORKChoiceButtonView *buttonView = [[ORKChoiceButtonView alloc] initWithImageChoice:imageChoice];
            [buttonView.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttonViews addObject:buttonView];
            [self addSubview:buttonView];
        }
        
      //-->  _choiceLabel.textArray = labelTextArray;
        _buttonViews = buttonViews;
        
        for (UILabel *label in @[_choiceLabel, _placeHolderLabel]) {
            label.isAccessibilityElement = NO;
        }
        
         //----------
        
// NOTE: added code for "no preference label"
// so need to pass in a flag to turn button on or off...

        _noPrefButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _noPrefButton.exclusiveTouch = YES;
      //  [_noPrefButton setTitle:@"No Preference" forState:UIControlStateNormal];
     //   [_noPrefButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_noPrefButton setImage:[UIImage imageNamed:@"no_preference.png" ] forState:UIControlStateNormal];
        [_noPrefButton setImage:[UIImage imageNamed:@"no_preference_selected.png" ] forState:UIControlStateSelected];
       [_noPrefButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside]; 
       [self addSubview:_noPrefButton];
        
        //--> ORKEnableAutoLayoutForViews(@[_noPrefButton]);
        
        _noPrefLabel = [[UILabel alloc] init];
        [_noPrefLabel setText:@"(equally good or equally bad)"];
        [_noPrefLabel setTextColor:[UIColor grayColor]];
        [_noPrefLabel setTextAlignment:NSTextAlignmentCenter];
        [_noPrefLabel setFont:[UIFont italicSystemFontOfSize:12]];
        [self addSubview:_noPrefLabel];
   //-->     ORKEnableAutoLayoutForViews(@[_noPrefLabel]);

        //-----------

        
     //-->   ORKEnableAutoLayoutForViews(@[_placeHolderLabel, _choiceLabel]);
     //-->   ORKEnableAutoLayoutForViews(_buttonViews);
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_choiceLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_choiceLabel": _choiceLabel}]];
                                               
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_noPrefButton]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_noPrefButton": _noPrefButton}]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_noPrefLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_noPrefLabel": _noPrefLabel}]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_placeHolderLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_placeHolderLabel": _placeHolderLabel}]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolderLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_choiceLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];

    ORKChoiceButtonView *previousView = nil;
    for (ORKChoiceButtonView *buttonView in _buttonViews) {
        NSDictionary *views = NSDictionaryOfVariableBindings(buttonView, _choiceLabel,_noPrefButton,_noPrefLabel);
        
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonView]-15-[_noPrefButton]-[_noPrefLabel]-30-[_choiceLabel]|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:nil
                                                   views:views]];
        
        if (previousView) {
            // ButtonView left trailing
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:previousView
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0
                                                                 constant:SpacerWidth]];
            
            // All ButtonViews has equal width
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:previousView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
        } else {
            // ButtonView left trailing
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0
                                                                 constant:SpacerWidth]];
        }
        previousView = buttonView;
    }
    
    if (previousView) {
        // ButtonView right trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:previousView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-SpacerWidth]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setAnswer:(id)answer {
//-->    _answer = answer;
    
  //-->  NSArray *selectedIndexes = [_helper selectedIndexesForAnswer:answer];
    
 //-->   [self setSelectedIndexes:selectedIndexes];
}

- (void)resetLabelText {
    _placeHolderLabel.hidden = NO;
    _choiceLabel.hidden = !_placeHolderLabel.hidden;
    
}

- (void)setLabelText:(NSString *)text {
    _choiceLabel.text = text;
    _choiceLabel.textColor = [UIColor blackColor];
    
    _choiceLabel.hidden = NO;
    _placeHolderLabel.hidden = !_choiceLabel.hidden;
    
}

- (IBAction)buttonTapped:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.selected) {
        [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             ORKChoiceButtonView *buttonView = obj;
             if (buttonView.button != button) {
                 buttonView.button.selected = NO;
             } else {
                 //[self setLabelText:buttonView.labelText];
                 // set label text display under image buttons, e.g. the seleted item label
             }
             
         }];
         
        
    } else {
        [self resetLabelText];
    }
    
    
    
   // _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];
    
    if (button == _noPrefButton) {
    
#define kNoPreferenceAnswer @[@(-1)]

        [self setLabelText:@"No Preference"];
    //-->    NSString *no_pref_answer = [NSString stringWithFormat:@"%@=%@",_choiceLabel.textArray[0],_choiceLabel.textArray[1]];

    //-->    _answer = [NSArray arrayWithObject:no_pref_answer];
    }
    else {
        _noPrefButton.selected = NO;
        
        NSInteger more_pref_index = [[[self selectedIndexes] firstObject] integerValue];
        NSInteger less_pref_index = [[[self unselectedIndexes] firstObject]  integerValue];
  //-->      NSString *pref_answer = [NSString stringWithFormat:@"%@>%@",_choiceLabel.textArray[more_pref_index],_choiceLabel.textArray[less_pref_index]];
        
    //-->    [self setLabelText:pref_answer];
        
  //-->       _answer = [NSArray arrayWithObject:pref_answer];
        
       // _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];

    }

    
//    if ([_delegate respondsToSelector:@selector(selectionViewSelectionDidChange:)]) {
//        [_delegate selectionViewSelectionDidChange:self];
//    }
    
    }


- (NSArray *)selectedIndexes {
    NSMutableArray *array = [NSMutableArray new];
    
    [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         ORKChoiceButtonView *buttonView = obj;
         if (buttonView.button.selected)
         {
             [array addObject:@(idx)];
         }
     }];
    
    return [array copy];
}
- (NSArray *)unselectedIndexes {
    NSMutableArray *array = [NSMutableArray new];
    
    [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         ORKChoiceButtonView *buttonView = obj;
         if (!buttonView.button.selected)
         {
             [array addObject:@(idx)];
         }
     }];
    
    return [array copy];
}

- (void)setSelectedIndexes:(NSArray *)selectedIndexes {
    [selectedIndexes enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (![object isKindOfClass:[NSNumber class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"selectedIndexes should only containt objects of the NSNumber kind" userInfo:nil];
        }
        NSNumber *number = object;
        if (number.unsignedIntegerValue < _buttonViews.count) {
            ORKChoiceButtonView *buttonView = _buttonViews[number.unsignedIntegerValue];
            [buttonView button].selected = YES;
            [self setLabelText:buttonView.labelText];
        }
    }];
}

- (BOOL)isAccessibilityElement {
    return NO;
}



@end
