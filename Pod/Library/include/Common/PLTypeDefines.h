//
//  PLTypeDefines.h
//  PLCameraStreamingKit
//
//  Created on 15/3/26.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#ifndef PLCameraStreamingKit_PLTypeDefines_h
#define PLCameraStreamingKit_PLTypeDefines_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - Stream State


/*!
    @typedef    PLStreamState
    @abstract   PLStreamingSessin 的流状态。
    @since      v1.0.0
 */
typedef NS_ENUM(NSUInteger, PLStreamState) {
    /// PLStreamStateUnknow 未知状态，只会作为 init 的初始状态
    PLStreamStateUnknow = 0,
    /// PLStreamStateConnecting 连接中状态
    PLStreamStateConnecting,
    /// PLStreamStateConnected 已连接状态
    PLStreamStateConnected,
    /// PLStreamStateDisconnecting 断开连接中状态
    PLStreamStateDisconnecting,
    /// PLStreamStateDisconnected 已断开连接状态
    PLStreamStateDisconnected,
    /// PLStreamStateAutoReconnecting 正在等待自动重连状态
    PLStreamStateAutoReconnecting,
    /// PLStreamStateError 错误状态
    PLStreamStateError
};

#pragma mark - Network State Transition

/*!
    @typedef    PLNetworkStateTransition
    @abstract   网络切换状态变化
 */
typedef NS_ENUM(NSUInteger, PLNetworkStateTransition) {
    /// PLNetworkStateTransition 未知转换态，作为 init 初始
    PLNetworkStateTransitionUnknown = 0,
    /// PLNetworkStateTransitionUnconnectedToWiFi 无网切换到WiFi
    PLNetworkStateTransitionUnconnectedToWiFi,
    /// PLNetworkStateTransitionUnconnectedToWWAN 无网切换到WWAN(4G, 3G, etc)
    PLNetworkStateTransitionUnconnectedToWWAN,
    /// PLNetworkStateTransitionWiFiToUnconnected WiFi切换到无网
    PLNetworkStateTransitionWiFiToUnconnected,
    /// PLNetworkStateTransitionWWANToUnconnected WWAN切换到无网
    PLNetworkStateTransitionWWANToUnconnected,
    /// PLNetworkStateTransitionWiFiToWWAN WiFi切换至WWAN
    PLNetworkStateTransitionWiFiToWWAN,
    /// PLNetworkStateTransitionWWANToWiFi WWAN切换至WiFi
    PLNetworkStateTransitionWWANToWiFi,
};

/*!
 @typedef    PLStreamStartState
 @abstract   反馈推流操作开始的状态。
 @since      v2.0.0
 */
typedef NS_ENUM(NSUInteger, PLStreamStartStateFeedback) {
    /// PLStreamStartStateSuccess 成功开始推流
    PLStreamStartStateSuccess = 0,
    /// PLStreamStartStateSessionUnknownError session 发生未知错误无法启动
    PLStreamStartStateSessionUnknownError,
    /// PLStreamStartStateSessionStillRunning session 已经在运行中，无需重复启动
    PLStreamStartStateSessionStillRunning,
    /// PLStreamStartStateStreamURLUnauthorized session 当前的 StreamURL 没有被授权
    PLStreamStartStateStreamURLUnauthorized,
    /// PLStreamStartStateSessionConnectStreamError session 建立 socket 连接错误
    PLStreamStartStateSessionConnectStreamError
};

#pragma mark - Log

/*!
 @typedef    PLStreamLogLevel
 @abstract   推流日志级别。
 @since      v2.1.0
 */
typedef NS_ENUM(NSUInteger, PLStreamLogLevel){
    // No logs
    PLStreamLogLevelOff       = 0,
    // Error logs only
    PLStreamLogLevelError,
    // Error and warning logs
    PLStreamLogLevelWarning,
    // Error, warning and info logs
    PLStreamLogLevelInfo,
    // Error, warning, info and debug logs
    PLStreamLogLevelDebug,
    // Error, warning, info, debug and verbose logs
    PLStreamLogLevelVerbose,
};


#pragma mark - Error

/*!
    @typedef    PLStreamError
    @abstract   错误状态码。

    @constant   PLStreamErrorUnknow 未知错误
    @constant   PLStreamErrorUnknowOption rtmp 推流未知配置
    @constant   PLStreamErrorAccessDNSFailed dns 无法访问
    @constant   PLStreamErrorFailedToConnectSocket socket 连接失败
    @constant   PLStreamErrorSocksNegotiationFailed sockket negotiation 失败
    @constant   PLStreamErrorFailedToCreateSocket 创建 socket 失败
    @constant   PLStreamErrorHandshakeFailed    握手失败
    @constant   PLStreamErrorRTMPConnectFailed  rtmp 连接失败
    @constant   PLStreamErrorSendFailed 发送数据包失败
    @constant   PLStreamErrorServerRequestedClose   被服务端关闭
    @constant   PLStreamErrorNetStreamFailed    NetStream 失败
    @constant   PLStreamErrorNetStreamPlayFailed    NetStreamPlay 失败
    @constant   PLStreamErrorNetStreamPlayStreamNotFound    NetStreamPlay 为找到对应的流
    @constant   PLStreamErrorNetConnectionConnectInvalidApp 连接到无效的 rtmp 应用
    @constant   PLStreamErrorSanityFailed Sanity 失败
    @constant   PLStreamErrorSocketClosedByPeer Socket 被关闭
    @constant   PLStreamErrorRTMPConnectStreamFailed    rtmp 连接流失败
    @constant   PLStreamErrorSocketTimeout  socket 超时
    @constant   PLStreamErrorTLSConnectFailed   TLS 连接失败
    @constant   PLStreamErrorNoSSLOrTLSSupport  没有 SSL 或者 TLS 支持
    @constant   PLStreamErrorDNSResolveFailed   DNS 解析失败
 
    @since      v1.0.0
 */
typedef enum {
    PLStreamErrorUnknow =	-1,
    PLStreamErrorUnknowOption = -999,
    PLStreamErrorAccessDNSFailed = -1000,
    PLStreamErrorFailedToConnectSocket = -1001,
    PLStreamErrorSocksNegotiationFailed = -1002,
    PLStreamErrorFailedToCreateSocket = -1003,
    PLStreamErrorHandshakeFailed = -1004,
    PLStreamErrorRTMPConnectFailed = -1005,
    PLStreamErrorSendFailed = -1006,
    PLStreamErrorServerRequestedClose = -1007,
    PLStreamErrorNetStreamFailed = -1008,
    PLStreamErrorNetStreamPlayFailed = -1009,
    PLStreamErrorNetStreamPlayStreamNotFound = -1010,
    PLStreamErrorNetConnectionConnectInvalidApp = -1011,
    PLStreamErrorSanityFailed = -1012,
    PLStreamErrorSocketClosedByPeer = -1013,
    PLStreamErrorRTMPConnectStreamFailed = -1014,
    PLStreamErrorSocketTimeout = -1015,
    
    // SSL errors
    PLStreamErrorTLSConnectFailed = -1200,
    PLStreamErrorNoSSLOrTLSSupport = -1201,
    
    // DNS error
    PLStreamErrorDNSResolveFailed = -1300,
    
    // reconnect error
    PLStreamErrorReconnectFailed = -1400,
    
    /**
     @brief 正在采集的时候被音频事件打断但重启失败
     */
    PLCameraErroRestartAudioFailed = -1500,
    /**
     @brief 正在采集的时候音频服务重启尝试重连但是没有成功
     */
    PLCameraErroTryReconnectFailed = -1501,
    
    PLRTCStreamingErrorUnknown = -1,
    PLRTCStreamingErrorInitEngineFailed = -3000,
    PLRTCStreamingErrorRoomAuthFailed = -3001,
    PLRTCStreamingErrorJoinRoomFailed = -3002,
    PLRTCStreamingErrorOpenMicrophoneFailed = -3003,
    PLRTCStreamingErrorSubscribeFailed = -3004,
    PLRTCStreamingErrorPublishCameraFailed = -3005,
    PLRTCStreamingErrorConnectRoomFailed = -3006,
    PLRTCStreamingErrorSetVideoBitrateFailed = -3007
} PLStreamError;

#pragma mark - Video Streaming Quality

/*!
    @constant   kPLVideoStreamingQualityLow1
    @abstract   视频编码推流质量 low 1。

    @discussion 具体参数 fps: 12, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 150Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityLow1;

/*!
    @constant   kPLVideoStreamingQualityLow1
    @abstract   视频编码推流质量 low 2。

    @discussion 具体参数 fps: 15, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 264Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityLow2;

/*!
    @constant   kPLVideoStreamingQualityLow3
    @abstract   视频编码推流质量 low 3。

    @discussion 具体参数 fps: 15, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 350Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityLow3;

/*!
    @constant   kPLVideoStreamingQualityMedium1
    @abstract   视频编码推流质量 medium 1。
 
    @discussion 具体参数 fps: 30, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 512Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityMedium1;

/*!
    @constant   kPLVideoStreamingQualityMedium2
    @abstract   视频编码推流质量 medium 2。

    @discussion 具体参数 fps: 30, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 800Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityMedium2;

/*!
    @constant   kPLVideoStreamingQualityMedium3
    @abstract   视频编码推流质量 medium 3。

    @discussion 具体参数 fps: 30, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 1000Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityMedium3;

/*!
    @constant   kPLVideoStreamingQualityHigh1
    @abstract   视频编码推流质量 high 1。

    @discussion 具体参数 fps: 30, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 1200Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityHigh1;

/*!
    @constant   kPLVideoStreamingQualityHigh2
    @abstract   视频编码推流质量 high 2。

    @discussion 具体参数 fps: 30, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 1500Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityHigh2;

/*!
    @constant   kPLVideoStreamingQualityHigh3
    @abstract   视频编码推流质量 high 3。

    @discussion 具体参数 fps: 30, profile level: AVVideoProfileLevelH264Baseline31, video bitrate: 2000Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLVideoStreamingQualityHigh3;

#pragma mark - Audio Streaming Quality

/*!
    @constant   kPLAudioStreamingQualityHigh1
    @abstract   音频编码推流质量 high 1。

    @discussion 具体参数 audio bitrate: 64Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLAudioStreamingQualityHigh1;

/*!
    @constant   kPLAudioStreamingQualityHigh2
    @abstract   音频编码推流质量 high 2。

    @discussion 具体参数 audio bitrate: 96Kbps。
 
    @since      v1.0.0
 */
extern NSString *kPLAudioStreamingQualityHigh2;

/*!
 @constant   kPLAudioStreamingQualityHigh3
 @abstract   音频编码推流质量 high 3。
 
 @discussion 具体参数 audio bitrate: 128Kbps。
 
 @since      v1.0.0
 */
extern NSString *kPLAudioStreamingQualityHigh3;

// post with userinfo @{@"state": @(state)}. always posted via MainQueue.
extern NSString *PLStreamStateDidChangeNotification;
extern NSString *PLCameraAuthorizationStatusDidGetNotificaiton;
extern NSString *PLMicrophoneAuthorizationStatusDidGetNotificaiton;

extern NSString *PLCameraDidStartRunningNotificaiton;
extern NSString *PLMicrophoneDidStartRunningNotificaiton;
extern NSString *PLAudioComponentFailedToCreateNotification;

#pragma mark - Audio SampleRate

/*!
 @typedef    PLStreamingAudioSampleRate
 @abstract   音频编码采样率。
 
 @constant   PLStreamingAudioSampleRate_48000Hz 48000Hz 音频编码采样率
 @constant   PLStreamingAudioSampleRate_44100Hz 44100Hz 音频编码采样率
 @constant   PLStreamingAudioSampleRate_22050Hz 22050Hz 音频编码采样率
 @constant   PLStreamingAudioSampleRate_11025Hz 11025Hz 音频编码采样率
 
 @since      v1.0.0
 */
typedef NS_ENUM(NSUInteger, PLStreamingAudioSampleRate) {
    PLStreamingAudioSampleRate_48000Hz = 48000,
    PLStreamingAudioSampleRate_44100Hz = 44100,
    PLStreamingAudioSampleRate_22050Hz = 22050,
    PLStreamingAudioSampleRate_11025Hz = 11025,
};

#pragma mark - Audio BitRate

/*!
    @typedef    PLStreamingAudioBitRate
    @abstract   音频编码码率。
 
    @constant   PLStreamingAudioBitRate_64Kbps 64Kbps 音频码率
    @constant   PLStreamingAudioBitRate_96Kbps 96Kbps 音频码率
    @constant   PLStreamingAudioBitRate_128Kbps 128Kbps 音频码率

    @since      v1.0.0
 */
typedef enum {
    PLStreamingAudioBitRate_64Kbps = 64000,
    PLStreamingAudioBitRate_96Kbps = 96000,
    PLStreamingAudioBitRate_128Kbps = 128000,
} PLStreamingAudioBitRate;

#pragma mark - RTC Video Size

/*!
 @typedef    PLRTCVideoSizePreset
 @abstract   定义连麦时的视频大小。
 */
typedef NS_ENUM(NSUInteger, PLRTCVideoSizePreset) {
    PLRTCVideoSizePresetUnknown = 0,
    PLRTCVideoSizePreset180x320 = 1,    //16:9
    PLRTCVideoSizePreset240x320,        //4:3
    PLRTCVideoSizePreset240x424,        //16:9
    PLRTCVideoSizePreset384x640,        //16:9
    PLRTCVideoSizePreset480x640,        //4:3
    PLRTCVideoSizePreset540x720,        //4:3
    PLRTCVideoSizePreset540x960,        //16:9
    PLRTCVideoSizePreset720x960,        //4:3
    PLRTCVideoSizePreset720x1280        //16:9
};

/// 断线后是否自动重新加入房间，默认为 YES
extern const NSString *kPLRTCAutoRejoinKey;

/// 断线后自动重新加入房间的重试次数，默认为 3 次；
extern const NSString *kPLRTCRejoinTimesKey;

/// 连接的超时时间，单位是 ms，默认为 5000 ms，最小为 3000 ms
extern const NSString *kPLRTCConnetTimeoutKey;

///连麦状态
typedef NS_ENUM(NSUInteger, PLRTCState) {
    /// 未知状态，只会作为 init 时的初始状态
    PLRTCStateUnknown = 0,
    /// 已加入房间的状态
    PLRTCStateConnected,
    /// 已进入到连麦的状态
    PLRTCStateConferenceStarted,
    /// 连麦已结束的状态
    PLRTCStateConferenceStopped
};

/// 设备授权状态
typedef NS_ENUM(NSUInteger, PLAuthorizationStatus) {
    /// 还没有确定是否授权
    PLAuthorizationStatusNotDetermined = 0,
    /// 设备受限，一般在家长模式下设备会受限
    PLAuthorizationStatusRestricted,
    /// 拒绝授权
    PLAuthorizationStatusDenied,
    /// 已授权
    PLAuthorizationStatusAuthorized
};

typedef enum {
    /**
     @brief Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
     */
    PLVideoFillModeStretch,
    
    /**
     @brief Maintains the aspect ratio of the source image, adding bars of the specified background color
     */
    PLVideoFillModePreserveAspectRatio,
    
    /**
     @brief Maintains the aspect ratio of the source image, zooming in on its center to fill the view
     */
    PLVideoFillModePreserveAspectRatioAndFill
} PLVideoFillModeType;

typedef enum {
    /**
     @brief 由 PLCameraStreamingKit 提供的预设的音效配置
     */
    PLAudioEffectConfigurationType_Preset = 1,
    /**
     @brief 用户自定义音效配置
     */
    PLAudioEffectConfigurationType_Custom = 2
} PLAudioEffectConfigurationType;

typedef enum {
    PLAudioPlayerFileError_FileNotExist,
    PLAudioPlayerFileError_FileOpenFail,
    PLAudioPlayerFileError_FileReadingFail
} PLAudioPlayerFileError;

/**
 @brief 对音频数据进行处理的回调
 */
typedef void (^PLAudioEffectCustomConfigurationBlock)(void *inRefCon,
                                                      AudioUnitRenderActionFlags *ioActionFlags,
                                                      const AudioTimeStamp *inTimeStamp,
                                                      UInt32 inBusNumber,
                                                      UInt32 inNumberFrames,
                                                      AudioBufferList *ioData);

#endif
