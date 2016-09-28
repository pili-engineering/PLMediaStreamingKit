//
//  PLAttributeModel.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/23.
//  Copyright © 2016年 com.pili-engineering.private. All rights reserved.
//

#import "PLAttributeModel.h"
#import "PLAlertSpinner.h"

#import <Masonry/Masonry.h>

@interface PLAttributeModel()
@property (nonatomic, strong) UIView *view;
@end

@interface _PLTitleAttributeModel : PLAttributeModel
- (instancetype)initWithTitle:(NSString *)title;
@end

@interface _PLInformationAttributeModel : PLAttributeModel
- (instancetype)initWithTitle:(NSString *)title
      withInformationCallback:(id(^)(id info))informationCallback;
@end

@interface _PLSegmentAttributeModel : PLAttributeModel
- (instancetype)initWithTitle:(NSString *)title
                withSegements:(NSArray *)segments
             withDefaultIndex:(NSInteger)defaultIndex
         withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback;
@end

@interface _PLSpinnerAttributeModel : PLAttributeModel
- (instancetype)initWithTitle:(NSString *)title
                 withElements:(NSArray *)elements
             withDefaultIndex:(NSInteger)defaultIndex
         withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback;
@end

@interface _PLStepperAttributeModel : PLAttributeModel
- (instancetype)initWithTitle:(NSString *)title
                    withValue:(double)value
             withMinimumValue:(double)minimumValue
             withMaximumValue:(double)maximumValue
                withStepValue:(double)stepValue
         withValueChangedCallback:(void (^)(double value))valueChangedCallback;
@end

@interface _PLSliderAttributeModel : PLAttributeModel
- (instancetype)initWithWithTitle:(NSString *)title
                 withDefaultValue:(float)defaultValue
         withValueChangedCallback:(void (^)(float value))valueChangedCallback;
@end

@interface _PLButtonAttributeModel : PLAttributeModel
- (instancetype)initWithTitles:(NSArray *)titles
               withTapCallback:(void (^)(NSUInteger tapedIndex))tapCallback;
@end

@implementation PLAttributeModel

- (void)refreshInformation:(id)info {}

- (void)reset{}

+ (PLAttributeModel *)titleAttributeModelWithTitle:(NSString *)title
{
    return [[_PLTitleAttributeModel alloc] initWithTitle:title];
}

+ (PLAttributeModel *)informationAttributeModelWithTitle:(NSString *)title
                                 withInformationCallback:(id(^)(id info))informationCallback
{
    return [[_PLInformationAttributeModel alloc] initWithTitle:title
                                       withInformationCallback:informationCallback];
}

+ (PLAttributeModel *)segmentAttributeModelWithTitle:(NSString *)title
                                       withSegements:(NSArray *)segments
                                    withDefaultIndex:(NSInteger)defaultIndex
                                withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback
{
    return [[_PLSegmentAttributeModel alloc] initWithTitle:title
                                             withSegements:segments
                                          withDefaultIndex:defaultIndex
                                      withSelectedCallback:selectedCallback];
}

+ (PLAttributeModel *)spinnerAttributeModelWithTitle:(NSString *)title
                                        withElements:(NSArray *)elements
                                    withDefaultIndex:(NSInteger)defaultIndex
                                withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback
{
    return [[_PLSpinnerAttributeModel alloc] initWithTitle:title
                                              withElements:elements
                                          withDefaultIndex:defaultIndex
                                      withSelectedCallback:selectedCallback];
}

+ (PLAttributeModel *)stepperAttributeModelWithTitle:(NSString *)title
                                           withValue:(double)value
                                    withMinimumValue:(double)minimumValue
                                    withMaximumValue:(double)maximumValue  withStepValue:(double)stepValue
                                withValueChangedCallback:(void (^)(double value))valueChangedCallback {
    return [[_PLStepperAttributeModel alloc] initWithTitle:title withValue:value withMinimumValue:minimumValue withMaximumValue:maximumValue  withStepValue:stepValue withValueChangedCallback:valueChangedCallback];
}

+ (PLAttributeModel *)sliderAttributeModelWithTitle:(NSString *)title
                                   withDefaultValue:(float)defaultValue
                           withValueChangedCallback:(void (^)(float value))valueChangedCallback
{
    return [[_PLSliderAttributeModel alloc] initWithWithTitle:title withDefaultValue:defaultValue withValueChangedCallback:valueChangedCallback];
}

+ (PLAttributeModel *)buttonAttributeModelWithTitles:(NSArray *)titles
                                     withTapCallback:(void (^)(NSUInteger tapedIndex))tapCallback
{
    return [[_PLButtonAttributeModel alloc] initWithTitles:titles withTapCallback:tapCallback];
}

@end

@implementation _PLTitleAttributeModel

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [self init]) {
        self.view = ({
            UILabel *label = [[UILabel alloc] init];
            [label setText:title];
            label;
        });
    }
    return self;
}

@end

@implementation _PLInformationAttributeModel
{
    UILabel *_label;
    NSString *_title;
    NSString *(^_informationCallback)();
}

- (instancetype)initWithTitle:(NSString *)title
      withInformationCallback:(id(^)(id info))informationCallback
{
    if (self = [self init]) {
        _label = [[UILabel alloc] init];
        _title = title;
        _informationCallback = informationCallback;
        self.view = [[UIView alloc] init];
        [self.view addSubview:_label];
        
        [_label setText:[NSString stringWithFormat:@"%@: waiting for refreshing...", title]];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(21);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
    }
    return self;
}

- (void)refreshInformation:(id)info
{
    id information = _informationCallback(info);
    [_label setText:[NSString stringWithFormat:@"%@: %@", _title, information]];
}

@end

@implementation _PLSegmentAttributeModel
{
    void (^_selectedCallback)(NSInteger selectedIndex);
    NSInteger _defaultIndex;
    UISegmentedControl *_segements;
}

- (instancetype)initWithTitle:(NSString *)title
                withSegements:(NSArray *)segments
             withDefaultIndex:(NSInteger)defaultIndex
         withSelectedCallback:(void (^)(NSInteger))selectedCallback
{
    if (self = [self init]) {
        _selectedCallback = selectedCallback;
        _defaultIndex = defaultIndex;
        
        self.view = [[UIView alloc] init];
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:title];
        [label setFont:[UIFont systemFontOfSize:14]];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(21);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        _segements = [[UISegmentedControl alloc] initWithItems:segments];
        [_segements addTarget:self action:@selector(_onSelectSegment:) forControlEvents:UIControlEventValueChanged];
        _segements.selectedSegmentIndex = defaultIndex;
        
        [self.view addSubview:_segements];
        [_segements mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).with.offset(12);
            make.right.equalTo(self.view);
            make.centerY.equalTo(self.view);
        }];
    }
    return self;
}

- (void)_onSelectSegment:(UISegmentedControl *)segments
{
    if (_selectedCallback) {
        _selectedCallback(segments.selectedSegmentIndex);
    }
    [self.delegate onValueChanged:self];
}

- (void)reset {
    dispatch_async(dispatch_get_main_queue(), ^{
        _segements.selectedSegmentIndex = _defaultIndex;
    });
}

@end

@implementation _PLSpinnerAttributeModel
{
    void (^_selectedCallback)(NSInteger selectedIndex);
}

- (instancetype)initWithTitle:(NSString *)title
                 withElements:(NSArray *)elements
             withDefaultIndex:(NSInteger)defaultIndex
         withSelectedCallback:(void (^)(NSInteger selectedIndex))selectedCallback
{
    if (self = [self init]) {
        _selectedCallback = selectedCallback;
        
        self.view = [[UIView alloc] init];
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:title];
        [label setFont:[UIFont systemFontOfSize:14]];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(21);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        PLAlertSpinner *alertSpinner = [[PLAlertSpinner alloc] initWithTitles:elements
                                                             withDefaultIndex:defaultIndex];
        [alertSpinner addTarget:self action:@selector(_onSelectElement:)
               forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:alertSpinner];
        [alertSpinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).with.offset(12);
            make.right.equalTo(self.view);
            make.centerY.equalTo(self.view);
        }];
    }
    return self;
}

- (void)_onSelectElement:(PLAlertSpinner *)alertSpinner
{
    if (_selectedCallback) {
        _selectedCallback(alertSpinner.selectedIndex);
    }
    [self.delegate onValueChanged:self];
}

@end

@implementation _PLStepperAttributeModel
{
    void (^_valueChangedCallback)(double value);
    UIStepper *_stepper;
    double _value;
}

- (instancetype)initWithTitle:(NSString *)title withValue:(double)value withMinimumValue:(double)minimumValue withMaximumValue:(double)maximumValue withStepValue:(double)stepValue withValueChangedCallback:(void (^)(double))valueChangedCallback {
    if (self = [self init]) {
        _valueChangedCallback = valueChangedCallback;
        _value = value;
        
        self.view = [[UIView alloc] init];
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:title];
        [label setFont:[UIFont systemFontOfSize:14]];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(21);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        _stepper = [[UIStepper alloc] init];
        _stepper.value = value;
        _stepper.minimumValue = minimumValue;
        _stepper.maximumValue = maximumValue;
        _stepper.stepValue = stepValue;
        [_stepper addTarget:self action:@selector(_onValueChanged:)
               forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:_stepper];
        [_stepper mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).with.offset(12);
            make.right.equalTo(self.view);
            make.centerY.equalTo(self.view);
        }];
    }
    return self;
}

- (void)_onValueChanged:(UIStepper *)stepper {
    if (_valueChangedCallback) {
        _valueChangedCallback(stepper.value);
    }
    [self.delegate onValueChanged:self];
}

- (void)reset {
    _stepper.value = _value;
}

@end

@implementation _PLSliderAttributeModel
{
    UISlider *_slider;
    void (^_valueChangedCallback)(float value);
}

- (instancetype)initWithWithTitle:(NSString *)title
                 withDefaultValue:(float)defaultValue
         withValueChangedCallback:(void (^)(float value))valueChangedCallback
{
    if (self = [self init]) {
        
        self.view = [[UIView alloc] init];
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:title];
        [label setFont:[UIFont systemFontOfSize:14]];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(21);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        _slider = [[UISlider alloc] init];
        _slider.value = defaultValue;
        _slider.maximumValue = 1;
        _slider.minimumValue = 0;
        _slider.continuous = NO;
        [self.view addSubview:_slider];
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).with.offset(12);
            make.right.equalTo(self.view.mas_right);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        [_slider addTarget:self action:@selector(onSliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
        
        _valueChangedCallback = valueChangedCallback;
    }
    return self;
}

- (void)onSliderValueChanged:(UISlider *)slider
{
    if (_valueChangedCallback) {
        _valueChangedCallback(slider.value);
    }
}

@end

@implementation _PLButtonAttributeModel
{
    NSArray *_buttons;
    void (^_tapCallback)(NSUInteger tapedIndex);
}

- (instancetype)initWithTitles:(NSArray *)titles
               withTapCallback:(void (^)(NSUInteger tapedIndex))tapCallback
{
    if (self = [self init]) {
        _tapCallback = tapCallback;
        self.view = [[UIView alloc] init];
        _buttons = ({
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            UIButton *preButton = nil;
            for (NSString *title in titles) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [button setTitle:title forState:UIControlStateNormal];
                [buttons addObject:button];
                [self.view addSubview:button];
                [button addTarget:self action:@selector(onTapButton:)
                 forControlEvents:UIControlEventTouchUpInside];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (preButton) {
                        make.left.equalTo(preButton.mas_right);
                    } else {
                        make.left.equalTo(self.view);
                    }
                    make.centerY.equalTo(self.view.mas_centerY);
                    make.width.mas_equalTo(150);
                }];
                preButton = button;
            }
            buttons;
        });
    }
    return self;
}

- (void)onTapButton:(UIButton *)button
{
    NSUInteger tapedIndex = [_buttons indexOfObject:button];
    _tapCallback(tapedIndex);
}

@end
