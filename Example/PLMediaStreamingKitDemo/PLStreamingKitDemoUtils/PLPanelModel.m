//
//  PLPanelModel.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/23.
//  Copyright © 2016年 com.pili-engineering.private. All rights reserved.
//

#import "PLPanelModel.h"
#import "PLAttributeModel.h"

#import <Masonry/Masonry.h>

#define kPLPanelModelCellIdentifier @"kPLPanelModelCellIdentifier"
#define kElementHeight 45
#define kElementEdgeInsets UIEdgeInsetsMake(5, 10, 5, 10)
#define kScrollContentBottomHeight 30

@interface _PLPanelScrollView : UIScrollView
@property (nonatomic, readonly) UIView *wrapperView;
@property (nonatomic, strong) UIView *lastAttributeModelView;
@end

@interface PLPanelModel() <PLAttributeModelDelegate> @end

@implementation PLPanelModel
{
    NSMutableArray *_attributeModels;
    NSTimer *_intervalRefreshingTimer;
    _PLPanelScrollView *_panelScrollView;
    id (^_refreshingInformationCallback)();
}

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        _title = title;
        _panelScrollView = [[_PLPanelScrollView alloc] init];
        _panelScrollView.backgroundColor = [UIColor whiteColor];
        _attributeModels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (UIView *)view
{
    return _panelScrollView;
}

- (NSArray *)attributeModels
{
    return _attributeModels;
}

- (void)setAttributeModels:(NSArray *)attributeModels
{
    _panelScrollView.lastAttributeModelView = nil;
    _attributeModels = [[NSMutableArray alloc] initWithArray:attributeModels];
    for (NSUInteger i=0; i<attributeModels.count; ++i) {
        PLAttributeModel *attributeModel = [attributeModels objectAtIndex:i];
        [self _addAttributeModelIntoView:attributeModel];
        [attributeModel setIndex:i];
    }
    [_panelScrollView setNeedsLayout];
}

- (void)refreshInformationEachIntervals:(id (^)())refreshingCallback
{
    if (_intervalRefreshingTimer) {
        [_intervalRefreshingTimer invalidate];
    }
    _intervalRefreshingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_intervalRefreshingTimerFire:) userInfo:nil repeats:YES];
    _refreshingInformationCallback = refreshingCallback;
}

- (void)_intervalRefreshingTimerFire:(id)sender
{
    if (_refreshingInformationCallback) {
        [self refreshInformation:_refreshingInformationCallback()];
    }
}

- (void)refreshInformation:(id)information
{
    for (PLAttributeModel *attributeModel in _attributeModels) {
        [attributeModel refreshInformation:information];
    }
}


- (void)addAttributeModel:(PLAttributeModel *)attributeModel
{
    [_attributeModels addObject:attributeModel];
    [self _addAttributeModelIntoView:attributeModel];
    [attributeModel setIndex:_attributeModels.count - 1];
    [_panelScrollView setNeedsLayout];
}

- (void)_addAttributeModelIntoView:(PLAttributeModel *)attributeModel
{
    UIEdgeInsets elementEdgeInsets = kElementEdgeInsets;
    [_panelScrollView.wrapperView addSubview:attributeModel.view];
    attributeModel.delegate = self;
    [attributeModel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_panelScrollView.lastAttributeModelView) {
            make.top.equalTo(_panelScrollView.lastAttributeModelView.mas_bottom).with.offset(elementEdgeInsets.top);
        } else {
            make.top.equalTo(_panelScrollView.wrapperView).with.offset(elementEdgeInsets.top);
        }
        make.left.equalTo(_panelScrollView.wrapperView).with.offset(elementEdgeInsets.left);
        make.right.greaterThanOrEqualTo(_panelScrollView.wrapperView).with.offset(-elementEdgeInsets.right);
        make.height.mas_equalTo(kElementHeight);
    }];
    _panelScrollView.lastAttributeModelView = attributeModel.view;
}

- (void)onValueChanged:(PLAttributeModel *)attributeModel
{
    if (_onAnyAttributeValueChanged) {
        _onAnyAttributeValueChanged(attributeModel);
    }
}

@end

@implementation _PLPanelScrollView

- (instancetype)init
{
    if (self = [super init]) {
        _wrapperView = [[UIView alloc] init];
        [self addSubview:_wrapperView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _setContentHeight:CGRectGetMaxY(_lastAttributeModelView.frame) + kScrollContentBottomHeight];
}

- (void)_setContentHeight:(CGFloat)height
{
    self.contentSize= CGSizeMake(self.bounds.size.width, MAX(self.bounds.size.height, height));
    _wrapperView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

@end