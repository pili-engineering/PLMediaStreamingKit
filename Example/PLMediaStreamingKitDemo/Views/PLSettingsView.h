//
//  PLSettingsView.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/9.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLSettings.h"


NS_ASSUME_NONNULL_BEGIN

@class PLSettingsView;

@protocol PLSettingsViewDelegate <NSObject>

@optional

- (void)settingsView:(PLSettingsView *)settingsView didChanged:(PLSettings *)settings;

@end




@interface PLSettingsView : UIView

@property (nonatomic, assign) id<PLSettingsViewDelegate> delegate;
// URL 输入框
@property (nonatomic, strong) UITextField *urlTextField;

// 列表 view 的父视图
@property (nonatomic, strong) UIView *listSuperView;

@property (nonatomic,strong) PLSettings *mSettings;


- (id)initWithFrame:(CGRect)frame pushURL:(NSString *)pushURL;

@end

NS_ASSUME_NONNULL_END
