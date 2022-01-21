//
//  PLSettings.h
//  PLMediaStreamingKitDemo
//
//  Created by 孙慕 on 2021/11/16.
//  Copyright © 2021 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    PLStreamTypeAll = 0,                 // 音视频
    PLStreamTypeAudioOnly = 1,           // 纯音频
    PLStreamTypeImport = 2,              // 外部导入
    PLStreamTypeScreen = 3,              // 录屏
} PLStreamType;

@interface PLVideoSettings : NSObject
@property (nonatomic, assign) BOOL continuousAutofocusEnable;
@property (nonatomic, assign) BOOL touchToFocusEnable;
@property (nonatomic, assign) BOOL smoothAutoFocusEnabled;
@property (nonatomic, assign) BOOL torchOn;
// sdk 视频采集配置
@property (nonatomic, strong) PLVideoCaptureConfiguration *videoCaptureConfiguration;
@end


@interface PLAudioSettings : NSObject
@property (nonatomic, assign) BOOL playback;
@property (nonatomic, assign) float inputGain;
@property (nonatomic, assign) BOOL allowAudioMixWithOthers;

// sdk 音频采集配置
@property (nonatomic, strong) PLAudioCaptureConfiguration *audioCaptureConfiguration;

@end


@interface PLSettings : NSObject
// 流类型
@property (nonatomic, assign) PLStreamType streamType;
// 协议类型
@property (nonatomic, assign) PLProtocolModel protocolModel;
// 画面填充模式
@property (nonatomic, assign) PLVideoFillModeType fillMode;
// QUIC 协议
@property (nonatomic, assign) BOOL quicEnable;
// 自适应码率
@property (nonatomic, assign) BOOL dynamicFrameEnable;
// 开启自适应码率调节功能 最小平均码率
@property (nonatomic, assign) NSUInteger minVideoBitRate;
// 自动重连
@property (nonatomic, assign) BOOL autoReconnectEnable;
// 开启网络切换监测
@property (nonatomic, assign) BOOL monitorNetworkStateEnable;
// 回调方法的调用间隔
@property (nonatomic, assign) NSTimeInterval statusUpdateInterval;
// 流信息更新间隔
@property (nonatomic, assign) CGFloat threshold;
// 发送队列最大容纳包数量。
@property (nonatomic, assign) NSUInteger maxCount;
// 控制系统屏幕自动锁屏是否关闭。
@property (nonatomic, assign) BOOL idleTimerDisable;

// 相机相关
@property (nonatomic, strong) PLVideoSettings *videoSettings;
// mic 相关
@property (nonatomic, strong) PLAudioSettings *audioSettings;


// sdk 视频流配置
@property (nonatomic, strong) PLVideoStreamingConfiguration *videoStreamConfiguration;
// sdk 音频流配置
@property (nonatomic, strong) PLAudioStreamingConfiguration *audioStreamingConfiguration;


@end

NS_ASSUME_NONNULL_END
