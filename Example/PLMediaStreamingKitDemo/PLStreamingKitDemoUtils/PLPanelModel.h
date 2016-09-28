//
//  PLPanelModel.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/23.
//  Copyright © 2016年 com.pili-engineering.private. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLAttributeModel;

@interface PLPanelModel : NSObject

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, strong) NSArray *attributeModels;
@property (nonatomic, strong) void (^onAnyAttributeValueChanged)(PLAttributeModel *valueChangedAttributeModel);

- (instancetype)initWithTitle:(NSString *)title;
- (void)addAttributeModel:(PLAttributeModel *)attributeModel;
- (void)refreshInformation:(id)information;
- (void)refreshInformationEachIntervals:(id (^)())refreshingCallback;

@end
