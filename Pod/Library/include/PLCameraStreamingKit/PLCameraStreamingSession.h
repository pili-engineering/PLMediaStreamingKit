//
//  PLCameraStreamingSession.h
//  PLCameraStreamingKit
//
//  Created on 15/4/1.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "PLStreamingKit.h"

@class PLCameraStreamingSession;

/// @abstract delegate 对象可以实现对应的方法来获取流的状态及设备授权情况。
@protocol PLCameraStreamingSessionDelegate <NSObject>

@optional
/// @abstract 流状态已变更的回调
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session streamStateDidChange:(PLStreamState)state;

/// @abstract 因产生了某个 error 而断开时的回调
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session didDisconnectWithError:(NSError *)error;

/// @abstract 当开始推流时，会每间隔 3s 调用该回调方法来反馈该 3s 内的流状态，包括视频帧率、音频帧率、音视频总码率
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status;

/// @abstract 摄像头授权状态发生变化的回调
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session didGetCameraAuthorizationStatus:(PLAuthorizationStatus)status;

/// @abstract 麦克风授权状态发生变化的回调
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session didGetMicrophoneAuthorizationStatus:(PLAuthorizationStatus)status;

/// @abstract 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致推流帧率下降
- (CVPixelBufferRef)cameraStreamingSession:(PLCameraStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/// @abstract 获取到麦克风原数据时的回调，需要注意的是这个回调在 AU Remote IO 线程，请不要做过于耗时的操作，否则可能阻塞该线程影响音频输出或其他未知问题
- (AudioBuffer *)cameraStreamingSession:(PLCameraStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer;

@end

#pragma mark - basic

/*!
 * @abstract 推流中的核心类。
 *
 * @discussion 一个 PLCameraStreamingSession 实例会包含了对视频源、音频源的控制，并且对流的操作及流状态的返回都是通过它来完成的。
 */
@interface PLCameraStreamingSession : NSObject

/*!
 * 是否开始推流，只读属性
 *
 * @discussion 该状态表达的是 streamingSession 有没有开始推流。当 streamState 为 PLStreamStateConnecting 或者 PLStreamStateConnected 时, isRunning 都会为 YES，所以它为 YES 时并不表示流一定已经建立连接，其从广义上表达 streamingSession 作为客户端对象的状态。
 */
@property (nonatomic, assign, readonly) BOOL    isRunning;

/// 视频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLVideoCaptureConfiguration  *videoCaptureConfiguration;

/// 音频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLAudioCaptureConfiguration  *audioCaptureConfiguration;

/// 视频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLVideoStreamingConfiguration  *videoStreamingConfiguration;

/// 音频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLAudioStreamingConfiguration  *audioStreamingConfiguration;


/*!
 * @abstract 摄像头的预览视图，在 PLCameraStreamingSession 初始化之后可以获取该视图
 *
 */
@property (nonatomic, strong, readonly) UIView * previewView;

/// 代理对象
@property (nonatomic, weak) id<PLCameraStreamingSessionDelegate> delegate;

/// 代理回调的队列
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

/**
 @brief previewView 中视频的填充方式，默认使用 PLVideoFillModePreserveAspectRatioAndFill
 */
@property(readwrite, nonatomic) PLVideoFillModeType fillMode;

/*!
 * 初始化方法
 *
 * @param videoCaptureConfiguration 视频采集的配置信息
 *
 * @param audioCaptureConfiguration 音频采集的配置信息
 *
 * @param videoStreamingConfiguration 视频编码及推流的配置信息
 *
 * @param audioStreamingConfiguration 音频编码及推流的配置信息
 *
 * @param stream Stream 对象
 *
 * @param videoOrientation 视频方向
 *
 * @return PLCameraStreamingSession 实例
 *
 * @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式，当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式，当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。
 */
- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream
                                 videoOrientation:(AVCaptureVideoOrientation)videoOrientation DEPRECATED_ATTRIBUTE;

- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream;
/*!
 * 销毁 session 的方法
 *
 * @discussion 销毁 PLCameraStreamingSession 的方法，销毁前不需要调用 stop 方法。
 */
- (void)destroy;

@end


#pragma mark - Category (PLStreamingKit)

@interface PLCameraStreamingSession (PLStreamingKit)

/// 流的状态，只读属性
@property (nonatomic, assign, readonly) PLStreamState   streamState;

/// 流对象
@property (nonatomic, strong) PLStream   *stream;

@property (nonatomic, copy) NSURL *pushURL;

/// 默认为 3s，可设置范围为 [1..30] 秒
@property (nonatomic, assign) NSTimeInterval    statusUpdateInterval;

@property (nonatomic, weak) id<PLStreamingSendingBufferDelegate> bufferDelegate;

/// [0..1], 不可超出这个范围, 默认为 0.5
@property (nonatomic, assign) CGFloat threshold;

/// Buffer 最多可包含的包数，默认为 300
@property (nonatomic, assign) NSUInteger    maxCount;
@property (nonatomic, assign, readonly) NSUInteger    currentCount;

/*!
 @method     startWithCompleted:
 @abstract   使用 stream 对象指定推流地址时请使用该方法开始推流。
 
 @param      handler 流连接的结果会通过该回调方法返回，携带是否已连接成功的布尔值，如果流连接成功将返回 YES，如果连接失败或当前流正在连接或已经连接将返回 NO
 
 @discussion 当 Streaming Session 创建并初始化好后（务必确认 stream 对象已设置好），就可以调用此方法开始推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 
 @warning    当采用 dynamic 认证且过期时，需要更新 Stream 对象，否则推流将失败。
 
 @see        stop
 @see        destroy
 
 @since      @v1.0.0
 */
- (void)startWithCompleted:(void (^)(BOOL success))handler DEPRECATED_ATTRIBUTE;

/*!
 @method     startWithFeedback:
 @abstract   使用 stream 对象指定推流地址时请使用该方法开始推流。
 
 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。
 
 @discussion 当 Streaming Session 创建并初始化好后（务必确认 stream 对象已设置好），就可以调用此方法开始推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 
 @warning    当采用 dynamic 认证且过期时，需要更新 Stream 对象，否则推流将失败。
 
 @see        stop
 @see        destroy
 
 @since      @v2.0.0
 */
- (void)startWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @method     startWithPushURL:feedback:
 @abstract   使用 streamURL 的方式指定推流地址时请使用该方法开始推流。
 
 @param      pushURL 推流地址，地址格式一般以 `rtmp://` 开头。
 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。
 
 @discussion 当 Streaming Session 创建并初始化好后就可以调用此方法开始推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 
 @see        stop
 @see        destroy
 
 @since      @v2.0.0
 */
- (void)startWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @method     restartWithCompleted:
 @abstract   使用 stream 对象指定推流地址时请使用该方法重新开始推流。
 
 @param      handler 流连接的结果会通过该回调方法返回，携带是否已连接成功的布尔值，如果流连接成功将返回 YES，如果连接失败或当前流正在连接或已经连接将返回 NO
 
 @discussion 当 Streaming Session 处于正在推流过程中，由于业务原因（如用户网络从 4G 切到 WIFI）需要快速重新推流时，可以调用此方法重新推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 
 @warning    当前 Streaming Session 处于正在推流状态时调用此方法时才会重新推流，其它状态时调用无效
 Streaming Session。
 当采用 dynamic 认证且过期时，需要更新 Stream 对象，否则推流将失败。
 
 @see        stop
 @see        destroy
 
 @since      @v1.2.2
 */
- (void)restartWithCompleted:(void (^)(BOOL success))handler DEPRECATED_ATTRIBUTE;

/*!
 @method     restartWithFeedback:
 @abstract   使用 stream 对象指定推流地址时请使用该方法重新开始推流。
 
 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。
 
 @discussion 当 Streaming Session 处于正在推流过程中，由于业务原因（如用户网络从 4G 切到 WIFI）需要快速重新推流时，可以调用此方法重新推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 
 @warning    当前 Streaming Session 处于正在推流状态时调用此方法时才会重新推流，其它状态时调用无效
 Streaming Session。
 当采用 dynamic 认证且过期时，需要更新 Stream 对象，否则推流将失败。
 
 @see        stop
 @see        destroy
 
 @since      @v2.0.0
 */
- (void)restartWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @method     restartWithPushURL:feedback:
 @abstract   使用 streamURL 的方式指定推流地址时请使用该方法重新开始推流。
 
 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。
 
 @discussion 当 Streaming Session 处于正在推流过程中，由于业务原因（如用户网络从 4G 切到 WIFI）需要快速重新推流时，可以调用此方法重新推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 
 @warning    当前 Streaming Session 处于正在推流状态时调用此方法时才会重新推流，其它状态时调用无效
 Streaming Session。
 
 @see        stop
 @see        destroy
 
 @since      @v2.0.0
 */
- (void)restartWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 * 结束推流
 */
- (void)stop;

/**
 @brief 重新加载视频推流配置
 
 @param videoStreamingConfiguration 新的视频编码配置
 @param videoCaptureConfiguration   新的视频采集配置
 */
- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration videoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration DEPRECATED_ATTRIBUTE;

- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration;

@end

#pragma mark - Category (CameraSource)

/*!
 * @category PLCameraStreamingSession(CameraSource)
 *
 * @discussion 与摄像头相关的接口
 */
@interface PLCameraStreamingSession (CameraSource)

/// default as AVCaptureDevicePositionBack.
@property (nonatomic, assign) AVCaptureDevicePosition   captureDevicePosition;

/**
 @brief 开启 camera 时的采集摄像头的旋转方向，默认为 AVCaptureVideoOrientationPortrait
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/// default as NO.
@property (nonatomic, assign, getter=isTorchOn) BOOL    torchOn;

/// default as YES.
@property (nonatomic, assign, getter=isContinuousAutofocusEnable) BOOL  continuousAutofocusEnable;

/// default as YES.
@property (nonatomic, assign, getter=isTouchToFocusEnable) BOOL touchToFocusEnable;

/// default as YES.
@property (nonatomic, assign, getter=isSmoothAutoFocusEnabled) BOOL  smoothAutoFocusEnabled;

/// default as (0.5, 0.5), (0,0) is top-left, (1,1) is bottom-right.
@property (nonatomic, assign) CGPoint   focusPointOfInterest;

/// 默认为 1.0，设置的数值需要小于等于 videoActiveForat.videoMaxZoomFactor，如果大于会设置失败。
@property (nonatomic, assign) CGFloat videoZoomFactor;

@property (nonatomic, strong, readonly) NSArray<AVCaptureDeviceFormat *> *videoFormats;

@property (nonatomic, retain) AVCaptureDeviceFormat *videoActiveFormat;

/**
 @brief 采集的视频的 sessionPreset，默认为 AVCaptureSessionPreset640x480
 */
@property (nonatomic, copy) NSString *sessionPreset;

/**
 @brief 采集的视频数据的帧率，默认为 30
 */
@property (nonatomic, assign) NSUInteger videoFrameRate;

/**
 @brief 前置预览是否开启镜像，默认为 YES
 */
@property (nonatomic, assign) BOOL previewMirrorFrontFacing;

/**
 @brief 后置预览是否开启镜像，默认为 NO
 */
@property (nonatomic, assign) BOOL previewMirrorRearFacing;

/**
 *  前置摄像头，推的流是否开启镜像，默认 NO
 */
@property (nonatomic, assign) BOOL streamMirrorFrontFacing;

/**
 *  后置摄像头，推的流是否开启镜像，默认 NO
 */
@property (nonatomic, assign) BOOL streamMirrorRearFacing;

- (void)toggleCamera;

/*!
 * 开启摄像头 session
 *
 * @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，在调用过 - (void)stopCaptureSession 方法后，
 * 如果要重新启用推流的摄像头，可以调用这个方法
 *
 * @see - (void)stopCaptureSession
 */
- (void)startCaptureSession;

/*!
 * 停止摄像头 session
 *
 * @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，当你需要暂且切换到你自己定制的摄像头做别的操作时，
 * 你需要调用这个方法来暂停当前 streaming session 对 captureSession 的占用。当需要恢复时，调用 - (void)startCaptureSession 方法。
 *
 * @see - (void)startCaptureSession
 */
- (void)stopCaptureSession;

/**
 @brief 由于硬件性能限制，为了保证推流的质量，下列 API 只支持 iPhone 5、iPad 3、iPod touch 4 及以上的设备，这些 API 在低端设备上将无效
 */


/**
 *  是否开启美颜
 */
-(void)setBeautifyModeOn:(BOOL)beautifyModeOn;

/**
 @brief 设置对应 Beauty 的程度参数.
 
 @param beautify 范围从 0 ~ 1，0 为不美颜
 */
-(void)setBeautify:(CGFloat)beautify;

/**
 *  设置美白程度（注意：如果美颜不开启，设置美白程度参数无效）
 *
 *  @param white 范围是从 0 ~ 1，0 为不美白
 */
-(void)setWhiten:(CGFloat)whiten;

/**
 *  设置红润的程度参数.（注意：如果美颜不开启，设置美白程度参数无效）
 *
 *  @param redden 范围是从 0 ~ 1，0 为不红润
 */

-(void)setRedden:(CGFloat)redden;

/**
 *  开启水印
 *
 *  @param wateMarkImage 水印的图片
 *  @param positio       水印的位置
 */
-(void)setWaterMarkWithImage:(UIImage *)wateMarkImage position:(CGPoint)position;

/**
 *  移除水印
 */
-(void)clearWaterMark;

@end


#pragma mark - Category (MicrophoneSource)

/*!
 * @category PLCameraStreamingSession(MicrophoneSource)
 *
 * @discussion 与麦克风相关的接口
 */
@interface PLCameraStreamingSession (MicrophoneSource)

/*!
 * @brief 返听功能
 */
@property (nonatomic, assign, getter=isPlayback) BOOL   playback;

@property (nonatomic, assign, getter=isMuted)   BOOL    muted;                   // default as NO.

/**
 @brief 麦克风采集的音量，设置范围为 0~1，各种机型默认值不同。
 
 @warning iPhone 6s 系列不支持调节麦克风采集的音量。
 */
@property (nonatomic, assign) float inputGain;

/**
 * @brief 音效，所有生效音效的一个数组。
 *
 * @see PLAudioEffectConfiguration
 */
@property (nonatomic, strong) NSArray<PLAudioEffectConfiguration *> *audioEffectConfigurations;

/**
 * @brief 绑定一个音频文件播放器。该播放器播放出的声音将和麦克风声音混和，并推流出去。
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 *
 * @param audioFilePath 音频文件路径
 * @see PLAudioPlayer
 */
- (PLAudioPlayer *)audioPlayerWithFilePath:(NSString *)audioFilePath;

/**
 * @brief 关闭当前的音频文件播放器
 */
- (void)closeCurrentAudio;

@end

#pragma mark - Categroy (Application)

/*!
 * @category PLCameraStreamingSession(Application)
 *
 * @discussion 与系统相关的接口
 */
@interface PLCameraStreamingSession (Application)

@property (nonatomic, assign, getter=isIdleTimerDisable) BOOL  idleTimerDisable;   // default as YES.

@end

#pragma mark - Category (Authorization)

/*!
 * @category PLCameraStreamingSession(Authorization)
 *
 * @discussion 与设备授权相关的接口
 */
@interface PLCameraStreamingSession (Authorization)

// Camera
+ (PLAuthorizationStatus)cameraAuthorizationStatus;

/**
 * 获取摄像头权限
 * @param handler 该 block 将会在主线程中回调。
 */
+ (void)requestCameraAccessWithCompletionHandler:(void (^)(BOOL granted))handler;

// Microphone
+ (PLAuthorizationStatus)microphoneAuthorizationStatus;

/**
 * 获取麦克风权限
 * @param handler 该 block 将会在主线程中回调。
 */
+ (void)requestMicrophoneAccessWithCompletionHandler:(void (^)(BOOL granted))handler;

@end

#pragma mark - Category (Info)

/*!
 * @category PLCameraStreamingSession(Info)
 *
 * @discussion sdk 相关信息
 */
@interface PLCameraStreamingSession (Info)

/*!
 @method     versionInfo
 @abstract   PLCameraStreamingKit 的 SDK 版本。
 
 @since      v1.8.1
 */
+ (NSString *)versionInfo;

@end
