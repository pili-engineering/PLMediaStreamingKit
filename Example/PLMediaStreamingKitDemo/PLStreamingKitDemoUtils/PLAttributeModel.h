//
//  PLAttributeModel.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/23.
//  Copyright © 2016年 com.pili-engineering.private. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLAttributeModel;

@protocol PLAttributeModelDelegate <NSObject>
- (void)onValueChanged:(PLAttributeModel *)attributeModel;
@end

@interface PLAttributeModel : NSObject

@property (nonatomic, readonly) UIView *view;
@property (nonatomic) NSUInteger index;
@property (nonatomic, weak) id<PLAttributeModelDelegate> delegate;

- (void)refreshInformation:(id)info;

- (void)reset;

+ (PLAttributeModel *)titleAttributeModelWithTitle:(NSString *)title;
+ (PLAttributeModel *)informationAttributeModelWithTitle:(NSString *)title
                                 withInformationCallback:(id(^)(id info))informationCallback;
+ (PLAttributeModel *)segmentAttributeModelWithTitle:(NSString *)title
                                       withSegements:(NSArray *)segments
                                        withDefaultIndex:(NSInteger)defaultIndex
                                    withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback;
+ (PLAttributeModel *)spinnerAttributeModelWithTitle:(NSString *)title
                                        withElements:(NSArray *)elements
                                    withDefaultIndex:(NSInteger)defaultIndex
                                withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback;
+ (PLAttributeModel *)stepperAttributeModelWithTitle:(NSString *)title
                                        withValue:(double)value
                                    withMinimumValue:(double)minimumValue
                                    withMaximumValue:(double)maximumValue
                                       withStepValue:(double)stepValue
                                withValueChangedCallback:(void (^)(double value))valueChangedCallback;
+ (PLAttributeModel *)sliderAttributeModelWithTitle:(NSString *)title
                                   withDefaultValue:(float)defaultValue
                           withValueChangedCallback:(void (^)(float value))valueChangedCallback;
+ (PLAttributeModel *)buttonAttributeModelWithTitles:(NSArray *)titles
                                     withTapCallback:(void (^)(NSUInteger tapedIndex))tapCallback;
@end
