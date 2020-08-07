//
//  PLSettingsView.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/9.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PLStreamTypeAll = 0,                 // 音视频
    PLStreamTypeAudioOnly = 1,           // 纯音频
    PLStreamTypeImport = 2,              // 外部导入
    PLStreamTypeScreen = 3,              // 录屏
} PLStreamType;

@class PLSettingsView;

@protocol PLSettingsViewDelegate <NSObject>

@optional

- (void)settingsView:(PLSettingsView *)settingsView didChangedSession:(PLMediaStreamingSession *)mediaSession streamSession:(PLStreamingSession *)streamSession ;

@end


@interface PLSettingsView : UIView

@property (nonatomic, assign) id<PLSettingsViewDelegate> delegate;
// URL 输入框
@property (nonatomic, strong) UITextField *urlTextField;
// 流类型
@property (nonatomic, assign) PLStreamType streamType;
// 列表 view 的父视图
@property (nonatomic, strong) UIView *listSuperView;

- (id)initWithFrame:(CGRect)frame mediaSession:(PLMediaStreamingSession *)mediaSession streamSession:(PLStreamingSession *)streamSession pushURL:(NSString *)pushURL;

@end

NS_ASSUME_NONNULL_END
