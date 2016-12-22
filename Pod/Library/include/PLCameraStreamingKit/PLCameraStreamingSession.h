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
 *
 * @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
DEPRECATED_MSG_ATTRIBUTE("PLCameraStreamingSession 已废弃, 请使用 PLMediaStreamingSession")
@interface PLCameraStreamingSession : NSObject

/*!
 * 是否开始推流，只读属性
 *
 * @discussion 该状态表达的是 streamingSession 有没有开始推流。当 streamState 为 PLStreamStateConnecting 或者 PLStreamStateConnected 时, isRunning 都会为 YES，所以它为 YES 时并不表示流一定已经建立连接，其从广义上表达 streamingSession 作为客户端对象的状态。
 *
 * @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
@property (nonatomic, assign, readonly) BOOL    isRunning DEPRECATED_ATTRIBUTE;

/// 视频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLVideoCaptureConfiguration  *videoCaptureConfiguration DEPRECATED_ATTRIBUTE;

/// 音频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLAudioCaptureConfiguration  *audioCaptureConfiguration DEPRECATED_ATTRIBUTE;

/// 视频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLVideoStreamingConfiguration  *videoStreamingConfiguration DEPRECATED_ATTRIBUTE;

/// 音频编码及推流配置，只读
@property (nonatomic, copy, readonly) PLAudioStreamingConfiguration  *audioStreamingConfiguration DEPRECATED_ATTRIBUTE;


/*!
 * @abstract 摄像头的预览视图，在 PLCameraStreamingSession 初始化之后可以获取该视图
 *
 * @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
@property (nonatomic, strong, readonly) UIView * previewView DEPRECATED_ATTRIBUTE;

/*!
 * @abstract 代理对象
 *
 * @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
@property (nonatomic, weak) id<PLCameraStreamingSessionDelegate> delegate DEPRECATED_ATTRIBUTE;

/// 代理回调的队列
@property (nonatomic, strong) dispatch_queue_t delegateQueue DEPRECATED_ATTRIBUTE;

/**
 @brief previewView 中视频的填充方式，默认使用 PLVideoFillModePreserveAspectRatioAndFill
 */
@property(readwrite, nonatomic) PLVideoFillModeType fillMode DEPRECATED_ATTRIBUTE;

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
 
 * @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream
                                 videoOrientation:(AVCaptureVideoOrientation)videoOrientation __deprecated;

- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream __deprecated;

- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream
                                      eaglContext:(EAGLContext *)eaglContext __deprecated;

/*!
 * 销毁 session 的方法
 *
 * @discussion 销毁 PLCameraStreamingSession 的方法，销毁前不需要调用 stop 方法。
 *
 * @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
- (void)destroy __deprecated;

@end


#pragma mark - Category (PLStreamingKit)

@interface PLCameraStreamingSession (PLStreamingKit)

/// 流的状态，只读属性
@property (nonatomic, assign, readonly) PLStreamState   streamState DEPRECATED_ATTRIBUTE;

/// 流对象
@property (nonatomic, strong) PLStream   *stream DEPRECATED_ATTRIBUTE;

@property (nonatomic, copy) NSURL *pushURL DEPRECATED_ATTRIBUTE;

/// 默认为 3s，可设置范围为 [1..30] 秒
@property (nonatomic, assign) NSTimeInterval    statusUpdateInterval DEPRECATED_ATTRIBUTE;

/// [0..1], 不可超出这个范围, 默认为 0.5
@property (nonatomic, assign) CGFloat threshold DEPRECATED_ATTRIBUTE;

/*!
 @property   receiveTimeout
 @abstract   网络连接和接收数据超时。
 
 @discussion 以秒作为单位。默认为 15s, 设定最小数值不得低于 3s，否则不变更。
 
 @see        sendTimeout
 
 @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 
 @since      v2.1.2
 */
@property (nonatomic, assign) int   receiveTimeout DEPRECATED_ATTRIBUTE;

/*!
 @property   sendTimeout
 @abstract   网络发送数据超时。
 
 @discussion 以秒作为单位。默认为 3s, 设定最小数值不得低于 3s，否则不变更。
 
 @warning PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 
 @see        receiveTimeout
 
 @since      v2.1.2
 */
@property (nonatomic, assign) int   sendTimeout DEPRECATED_ATTRIBUTE;

/// Buffer 最多可包含的包数，默认为 300
@property (nonatomic, assign) NSUInteger    maxCount DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign, readonly) NSUInteger    currentCount DEPRECATED_ATTRIBUTE;

/*!
 @property   dynamicFrameEnable
 @abstract   开启动态帧率功能，自动调整的最大帧率不超过 videoStreamingConfiguration.expectedSourceVideoFrameRate。该功能默认为关闭状态。
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
@property (nonatomic,assign, getter=isDynamicFrameEnable) BOOL dynamicFrameEnable DEPRECATED_ATTRIBUTE;

/*!
 @property   monitorNetworkStateEnable
 @abstract   开启网络切换监测，默认处于关闭状态
 
 @discussion 打开该开关后，需实现回调函数 connectionChangeActionCallback，以完成在某种网络切换状态下对推流连接的处理判断。
 @see        connectionChangeActionCallback
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
@property (nonatomic, assign, getter=isMonitorNetworkStateEnable) BOOL monitorNetworkStateEnable DEPRECATED_ATTRIBUTE;

/*!
 @property   autoReconnectEnable
 @abstract   自动断线重连开关，默认关闭。
 
 @discussion 该方法在推流 SDK 内部实现断线自动重连。若开启此机制，则当推流因异常导致中断时，-streamingSession:didDisconnectWithError:回调不会马上被触发，推流将进行最多三次自动重连，每次重连的等待时间会由初次的0~2s递增至最大10s。等待重连期间，推流状态 streamState 会变为 PLStreamStateAutoReconnecting。一旦三次自动重连仍无法成功连接，则放弃治疗，-streamingSession:didDisconnectWithError:回调将被触发。
 该机制默认关闭，用户可在 -streamingSession:didDisconnectWithError: 方法中自定义添加断线重连处理逻辑。
 @see        connectionInterruptionHandler
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
@property (nonatomic, assign, getter=isAutoReconnectEnable) BOOL autoReconnectEnable DEPRECATED_ATTRIBUTE;

/*!
 @method     enableAdaptiveBitrateControlWithMinVideoBitRate:
 @abstract   开启自适应码率调节功能
 
 @param      minVideoBitRate 最小平均码率
 
 @discussion 该方法在推流 SDK 内部实现动态码率调节。开启该机制时，需设置允许调节的最低码率，以便使自动调整后的码率不会低于该范围。该机制根据网络吞吐量来调节推流的码率，在网络带宽变小导致发送缓冲区数据持续增长时，SDK 内部将适当降低推流码率，若情况得不到改善，则会重复该过程直至平均码率降至用户设置的最低值；反之，当一段时间内网络带宽充裕，SDK 将适当增加推流码率，直至达到预设的推流码率。
 自适应码率机制默认关闭，用户可利用 -streamingSession:streamStatusDidUpdate 回调数据实现自定义版本的码率调节功能。
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
- (void)enableAdaptiveBitrateControlWithMinVideoBitRate:(NSUInteger)minVideoBitRate __deprecated;

/*!
 @method     disableAdaptiveBitrateControl
 @abstract   关闭自适应码率调节功能，默认即为关闭状态
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
- (void)disableAdaptiveBitrateControl __deprecated;

/*!
 @property    adaptiveQualityMode
 @abstract    自适应质量(码率/帧率)控制模式
 
 @discussion  提供码率调整优先、帧率调整优先以及混合调整三种模式，只有在同时打开自适应码率开关 (enableAdaptiveBitrateControlWithMinVideoBitRate:) 以及动态帧率开关 (dynamicFrameEnable) 时，该模式才起到控制作用。默认为混合调整模式，即弱网时同时调节帧率跟码率。
 @see         PLStreamAdaptiveQualityMode
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
@property (nonatomic, assign) PLStreamAdaptiveQualityMode adaptiveQualityMode DEPRECATED_ATTRIBUTE;

/*!
 @property   connectionInterruptionHandler
 @abstract   推流断开用户回调
 
 @discussion 该回调函数传入参数为推流断开产生的错误信息 error。返回值为布尔值，YES 表示在该错误状态下允许推流自动重连，NO 则代表不允许自动重连。本回调函数与 autoReconnectEnable 开关配合作用，只有在该开关开启时，本回调会在自动重连之前被调用，并通过返回值判断是否继续自动重连。若用户未设置该回调方法，则按默认策略最多进行三次自动重连。
 
 @warning    该回调会在主线程中执行
 
 @see        autoReconnectEnable
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
@property (nonatomic, copy) _Nullable ConnectionInterruptionHandler connectionInterruptionHandler DEPRECATED_ATTRIBUTE;

/*!
 @property   connectionChangeActionCallback
 @abstract   网络切换用户回调
 
 @discussion 该回调函数与 monitorNetworkStateEnable 开关配合作用，只有将该开关开启时，该回调才会执行。该回调函数传入参数为当前网络的切换状态 PLNetworkStateTransition。返回值为布尔值，YES 表示在某种切换状态下允许推流自动重启，NO 则代表该状态下不应自动重启。该回调与自动重连回调 connectionInterruptionHandler 的区别在于，当推流网络从 WWAN 切换到 WiFi 时，推流不会被断开而继续使用 WWAN，此时自动重连机制不会被触发，SDK 内部会调用 connectionChangeActionCallback 来判断是否需要重启推流以使用优先级更高的网络。值得注意的是，在开启自动重连开关 autoReconnectEnable，并实现了本回调的情况下，推流时网络从 WiFi 切换到 WWAN，SDK 将优先执行本回调函数判断是否主动重启推流。如果用户选择在此情况下不主动重启，则等推流连接超时后将自动重连决定权交予 connectionInterruptionHandler 判断。如果两个回调均未被实现，则该情况下会默认断开推流以防止用户流量消耗。
 
 @warning    该回调会在主线程中执行
 
 @see        monitorNetworkStateEnable
 @see        connectionInterruptionHandler
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
@property (nonatomic, copy) _Nullable ConnectionChangeActionCallback connectionChangeActionCallback DEPRECATED_ATTRIBUTE;

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
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 @since      @v1.0.0
 */
- (void)startWithCompleted:(void (^)(BOOL success))handler __deprecated;

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
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 @since      @v2.0.0
 */
- (void)startWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler __deprecated;

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
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 @since      @v2.0.0
 */
- (void)startWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler __deprecated;

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
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 @see        stop
 @see        destroy
 
 @since      @v1.2.2
 */
- (void)restartWithCompleted:(void (^)(BOOL success))handler __deprecated;

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
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 
 @see        stop
 @see        destroy
 
 @since      @v2.0.0
 */
- (void)restartWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler __deprecated;

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
 @warning    PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 
 @see        stop
 @see        destroy
 
 @since      @v2.0.0
 */
- (void)restartWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler __deprecated;

/*!
 @abstract  结束推流
 @warning   PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
- (void)stop __deprecated;

/**
 @brief 重新加载视频推流配置
 
 @param videoStreamingConfiguration 新的视频编码配置
 @param videoCaptureConfiguration   新的视频采集配置
 @warning   PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration videoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration __deprecated;

- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration __deprecated;

@end

#pragma mark - Category (CameraSource)

/*!
 * @category PLCameraStreamingSession(CameraSource)
 *
 * @discussion 与摄像头相关的接口
 */
@interface PLCameraStreamingSession (CameraSource)

/// default as AVCaptureDevicePositionBack.
@property (nonatomic, assign) AVCaptureDevicePosition   captureDevicePosition DEPRECATED_ATTRIBUTE;

/**
 @brief 开启 camera 时的采集摄像头的旋转方向，默认为 AVCaptureVideoOrientationPortrait
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation DEPRECATED_ATTRIBUTE;

/// default as NO.
@property (nonatomic, assign, getter=isTorchOn) BOOL    torchOn DEPRECATED_ATTRIBUTE;

/*!
 @property  continuousAutofocusEnable
 @abstract  连续自动对焦。该属性默认开启。
 */
@property (nonatomic, assign, getter=isContinuousAutofocusEnable) BOOL  continuousAutofocusEnable DEPRECATED_ATTRIBUTE;

/*!
 @property  touchToFocusEnable
 @abstract  手动点击屏幕进行对焦。该属性默认开启。
 */
@property (nonatomic, assign, getter=isTouchToFocusEnable) BOOL touchToFocusEnable DEPRECATED_ATTRIBUTE;

/*!
 @property  smoothAutoFocusEnabled
 @abstract  该属性适用于视频拍摄过程中用来减缓因自动对焦产生的镜头伸缩，使画面不因快速的对焦而产生抖动感。该属性默认开启。
 */
@property (nonatomic, assign, getter=isSmoothAutoFocusEnabled) BOOL  smoothAutoFocusEnabled DEPRECATED_ATTRIBUTE;

/// default as (0.5, 0.5), (0,0) is top-left, (1,1) is bottom-right.
@property (nonatomic, assign) CGPoint   focusPointOfInterest DEPRECATED_ATTRIBUTE;

/// 默认为 1.0，设置的数值需要小于等于 videoActiveForat.videoMaxZoomFactor，如果大于会设置失败。
@property (nonatomic, assign) CGFloat videoZoomFactor DEPRECATED_ATTRIBUTE;

@property (nonatomic, strong, readonly) NSArray<AVCaptureDeviceFormat *> *videoFormats DEPRECATED_ATTRIBUTE;

@property (nonatomic, retain) AVCaptureDeviceFormat *videoActiveFormat DEPRECATED_ATTRIBUTE;

/**
 @brief 采集的视频的 sessionPreset，默认为 AVCaptureSessionPreset640x480
 */
@property (nonatomic, copy) NSString *sessionPreset DEPRECATED_ATTRIBUTE;

/**
 @brief 采集的视频数据的帧率，默认为 30
 */
@property (nonatomic, assign) NSUInteger videoFrameRate DEPRECATED_ATTRIBUTE;

/**
 @brief 前置预览是否开启镜像，默认为 YES
 */
@property (nonatomic, assign) BOOL previewMirrorFrontFacing DEPRECATED_ATTRIBUTE;

/**
 @brief 后置预览是否开启镜像，默认为 NO
 */
@property (nonatomic, assign) BOOL previewMirrorRearFacing DEPRECATED_ATTRIBUTE;

/**
 *  前置摄像头，推的流是否开启镜像，默认 NO
 */
@property (nonatomic, assign) BOOL streamMirrorFrontFacing DEPRECATED_ATTRIBUTE;

/**
 *  后置摄像头，推的流是否开启镜像，默认 NO
 */
@property (nonatomic, assign) BOOL streamMirrorRearFacing DEPRECATED_ATTRIBUTE;

- (void)toggleCamera __deprecated;

/*!
 * 开启摄像头 session
 *
 * @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，在调用过 - (void)stopCaptureSession 方法后，
 * 如果要重新启用推流的摄像头，可以调用这个方法
 *
 * @see - (void)stopCaptureSession
 * @warning   PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 *
 */
- (void)startCaptureSession __deprecated;

/*!
 * 停止摄像头 session
 *
 * @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，当你需要暂且切换到你自己定制的摄像头做别的操作时，
 * 你需要调用这个方法来暂停当前 streaming session 对 captureSession 的占用。当需要恢复时，调用 - (void)startCaptureSession 方法。
 *
 * @see - (void)startCaptureSession
 * @warning   PLCameraStreamingSession 从 v2.1.6 开始废弃，请使用 PLMediaStreamingSession
 */
- (void)stopCaptureSession __deprecated;

/**
 @brief 由于硬件性能限制，为了保证推流的质量，下列 API 只支持 iPhone 5、iPad 3、iPod touch 4 及以上的设备，这些 API 在低端设备上将无效
 */


/**
 *  是否开启美颜
 */
-(void)setBeautifyModeOn:(BOOL)beautifyModeOn __deprecated;

/**
 @brief 设置对应 Beauty 的程度参数.
 
 @param beautify 范围从 0 ~ 1，0 为不美颜
 */
-(void)setBeautify:(CGFloat)beautify __deprecated;

/**
 *  设置美白程度（注意：如果美颜不开启，设置美白程度参数无效）
 *
 *  @param white 范围是从 0 ~ 1，0 为不美白
 */
-(void)setWhiten:(CGFloat)whiten __deprecated;

/**
 *  设置红润的程度参数.（注意：如果美颜不开启，设置美白程度参数无效）
 *
 *  @param redden 范围是从 0 ~ 1，0 为不红润
 */

-(void)setRedden:(CGFloat)redden __deprecated;

/**
 *  开启水印
 *
 *  @param wateMarkImage 水印的图片
 *  @param positio       水印的位置
 */
-(void)setWaterMarkWithImage:(UIImage *)wateMarkImage position:(CGPoint)position __deprecated;

/**
 *  移除水印
 */
-(void)clearWaterMark __deprecated;

/**
 *  @brief 视频截图
 *
 *  @param handler 类型为 PLStreamScreenshotHandler 的 block
 *
 *  @discussion 截图操作为异步，完成后将通过 handler 回调返回 UIImage 类型图片数据，
 *              请在Handler里自行指定您所需要操作 UIImage 的队列。
 *
 *  @since v2.2.0
 *
 */
- (void)getScreenshotWithCompletionHandler:(nullable PLStreamScreenshotHandler)handler __deprecated;

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
@property (nonatomic, assign, getter=isPlayback) BOOL   playback DEPRECATED_ATTRIBUTE;

@property (nonatomic, assign, getter=isMuted)   BOOL    muted DEPRECATED_ATTRIBUTE;                   // default as NO.

/*!
 @brief 是否允许在后台与其他 App 的音频混音而不被打断，默认关闭
 */
@property (nonatomic, assign) BOOL allowAudioMixWithOthers DEPRECATED_ATTRIBUTE;

/*!
 @brief 音频被其他 app 中断开始时会回调该函数，注意回调不在主线程进行。
 */
@property (nonatomic, copy) PLAudioSessionDidBeginInterruptionCallback _Nullable audioSessionBeginInterruptionCallback DEPRECATED_ATTRIBUTE;

/*!
 @brief 音频中断结束时回调，即其他 app 结束打断音频操作时会回调该函数，注意回调不在主线程进行。
 */
@property (nonatomic, copy) PLAudioSessionDidEndInterruptionCallback _Nullable audioSessionEndInterruptionCallback DEPRECATED_ATTRIBUTE;


/**
 @brief 麦克风采集的音量，设置范围为 0~1，各种机型默认值不同。
 
 @warning iPhone 6s 系列不支持调节麦克风采集的音量。
 */
@property (nonatomic, assign) float inputGain DEPRECATED_ATTRIBUTE;

/**
 * @brief 音效，所有生效音效的一个数组。
 *
 * @see PLAudioEffectConfiguration
 */
@property (nonatomic, strong) NSArray<PLAudioEffectConfiguration *> *audioEffectConfigurations DEPRECATED_ATTRIBUTE;

/**
 * @brief 绑定一个音频文件播放器。该播放器播放出的声音将和麦克风声音混和，并推流出去。
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 *
 * @param audioFilePath 音频文件路径
 * @see PLAudioPlayer
 */
- (PLAudioPlayer *)audioPlayerWithFilePath:(NSString *)audioFilePath __deprecated;

/**
 * @brief 关闭当前的音频文件播放器
 */
- (void)closeCurrentAudio __deprecated;

@end

#pragma mark - Categroy (Application)

/*!
 * @category PLCameraStreamingSession(Application)
 *
 * @discussion 与系统相关的接口
 */
@interface PLCameraStreamingSession (Application)

@property (nonatomic, assign, getter=isIdleTimerDisable) BOOL  idleTimerDisable DEPRECATED_ATTRIBUTE;   // default as YES.

@end

#pragma mark - Category (Authorization)

/*!
 * @category PLCameraStreamingSession(Authorization)
 *
 * @discussion 与设备授权相关的接口
 */
@interface PLCameraStreamingSession (Authorization)

// Camera
+ (PLAuthorizationStatus)cameraAuthorizationStatus __deprecated;

/**
 * 获取摄像头权限
 * @param handler 该 block 将会在主线程中回调。
 */
+ (void)requestCameraAccessWithCompletionHandler:(void (^)(BOOL granted))handler __deprecated;

// Microphone
+ (PLAuthorizationStatus)microphoneAuthorizationStatus __deprecated;

/**
 * 获取麦克风权限
 * @param handler 该 block 将会在主线程中回调。
 */
+ (void)requestMicrophoneAccessWithCompletionHandler:(void (^)(BOOL granted))handler __deprecated;

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
+ (NSString *)versionInfo __deprecated;

@end
