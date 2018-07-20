//
//  PLRTCConfiguration.h
//  PLMediaStreamingKit
//
//  Created by lawder on 16/8/16.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTypeDefines.h"

@interface PLRTCConfiguration : NSObject
<
NSCopying
>

/**
 @brief 设置连麦者的画面尺寸，默认是 PLRTCVideoSizePresetDefault，即使用传入的视频的尺寸；
 */
@property (nonatomic, assign) PLRTCVideoSizePreset videoSize;
@property (nonatomic, assign) PLRTCConferenceType conferenceType;

/**
 @brief 设置连麦合流的画面尺寸，若未设置，则合流的画面尺寸由 videoSize 决定；
 默认为：CGSizeZero，即连麦合流的画面尺寸等于 videoSize；
 */
@property (nonatomic, assign) CGSize mixVideoSize;

/**
 @brief 设置本地视频数据在连麦合流的画面中的大小和位置，若 mixVideoSize 未设置，则该值无效；
 默认为：CGRectNull
 */
@property (nonatomic, assign) CGRect localVideoRect;


+ (instancetype)defaultConfiguration;

-(instancetype)initWithVideoSize:(PLRTCVideoSizePreset)videoSize;

-(instancetype)initWithVideoSize:(PLRTCVideoSizePreset)videoSize
                  conferenceType:(PLRTCConferenceType)conferenceType;

@end
