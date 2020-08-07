//
//  PLShowDetailView.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/10.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLPasterView.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PLSetDetailViewOrientaion = 0,       // 旋转方向
    PLSetDetailViewBeauty = 1,           // 美颜设置
    PLSetDetailViewImagePush = 2,        // 图片推流设置
    PLSetDetailViewSticker = 3,          // 贴纸设置
    PLSetDetailViewWaterMark = 4,        // 水印设置
    PLSetDetailViewAudioMix = 5,         // 混音设置
    PLSetDetailViewAudioEffect = 6,      // 音效设置
    
} PLSetDetailViewType;

@class PLShowDetailView;

@protocol PLShowDetailViewDelegate <NSObject>

@optional

// 分栏点击的回调，包括旋转方向、图片推流、水印、音效的选择
- (void)showDetailView:(PLShowDetailView *)showDetailView didClickIndex:(NSInteger)index currentType:(PLSetDetailViewType)type;

// 美颜设置 view 调整参数的回调
- (void)showDetailView:(PLShowDetailView *)showDetailView didChangeBeautyMode:(BOOL)beautyMode beauty:(CGFloat)beauty white:(CGFloat)white red:(CGFloat)red;

// 贴纸设置 view 调整参数的回调
- (void)showDetailView:(PLShowDetailView *)showDetailView didAddStickerView:(PLPasterView *)stickerView;
- (void)showDetailView:(PLShowDetailView *)showDetailView didRemoveStickerView:(PLPasterView *)stickerView;
- (void)showDetailView:(PLShowDetailView *)showDetailView didRefreshStickerView:(PLPasterView *)stickerView;


// 混音设置 view 调整参数的回调
- (void)showDetailView:(PLShowDetailView *)showDetailView didUpdateAudioPlayer:(BOOL)play playBack:(BOOL)playBack file:(NSString *)file;
- (void)showDetailView:(PLShowDetailView *)showDetailView didUpdateAudioPlayVolume:(CGFloat)volume;
- (void)showDetailView:(PLShowDetailView *)showDetailView didUpdateAudioPlayProgress:(CGFloat)progress;

@end

@interface PLShowDetailView : UIView

@property (nonatomic, assign) id<PLShowDetailViewDelegate> delegate;
@property (nonatomic, strong) UISlider *progressSlider;

- (id)initWithFrame:(CGRect)frame backView:(UIView *)backView;

// 根据类型显示
- (void)showDetailSettingViewWithType:(PLSetDetailViewType)type;

// 隐藏所有设置 view
- (void)hideDetailSettingView;

@end

NS_ASSUME_NONNULL_END
