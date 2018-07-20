//
//  PLMediaStreamingSession.h
//  PLCameraStreamingKit
//
//  Created by lawder on 16/7/28.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLRTCStreamingSession.h"

@class PLMediaStreamingSession;

/// @abstract delegate 对象可以实现对应的方法来获取流的状态及设备授权情况。
@protocol PLMediaStreamingSessionDelegate <NSObject>

@optional

/// @abstract 流状态已变更的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state;

/// @abstract 因产生了某个 error 而断开时的回调，error 错误码的含义可以查看 PLTypeDefines.h 文件
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error;

/// @abstract 当开始推流时，会每间隔 3s 调用该回调方法来反馈该 3s 内的流状态，包括视频帧率、音频帧率、音视频总码率
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status;

/// @abstract 摄像头授权状态发生变化的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didGetCameraAuthorizationStatus:(PLAuthorizationStatus)status;

/// @abstract 麦克风授权状态发生变化的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didGetMicrophoneAuthorizationStatus:(PLAuthorizationStatus)status;

/// @abstract 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致推流帧率下降
- (CVPixelBufferRef)mediaStreamingSession:(PLMediaStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/// @abstract 获取到麦克风原数据时的回调，需要注意的是这个回调在 AU Remote IO 线程，请不要做过于耗时的操作，否则可能阻塞该线程影响音频输出或其他未知问题
- (AudioBuffer *)mediaStreamingSession:(PLMediaStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer;

/// @abstract 连麦状态已变更的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session rtcStateDidChange:(PLRTCState)state;

/// @abstract 因产生了某个 error 的回调，error 错误码的含义可以查看 PLTypeDefines.h 文件
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session rtcDidFailWithError:(NSError *)error;


/// @abstract 连麦时，将对方视频渲染到 remoteView 后的回调，可将 remoteView 添加到合适的 View 上将其显示出来。本接口在主队列中回调。
/// @warning 推出去的流中连麦的窗口位置在 rtcMixOverlayRectArray 中设定，与 remoteView 的位置没有关系。
/// @see rtcMixOverlayRectArray
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session userID:(NSString *)userID didAttachRemoteView:(UIView *)remoteView;

/// @abstract 连麦时，取消对方视频渲染到 remoteView 后的回调，可在该方法中将 remoteView 从父 View 中移除。本接口在主队列中回调。
/// @warning 推出去的流中连麦的窗口位置在 rtcMixOverlayRectArray 中设定，与 remoteView 的位置没有关系。
/// @see rtcMixOverlayRectArray
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session userID:(NSString *)userID didDetachRemoteView:(UIView *)remoteView;

/// @abstract 被 userID 从房间踢出
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didKickoutByUserID:(NSString *)userID;

/// @abstract  userID 加入房间
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didJoinConferenceOfUserID:(NSString *)userID;

/// @abstract userID 离开房间
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didLeaveConferenceOfUserID:(NSString *)userID;

/// @abstract 连麦时，SDK 内部渲染连麦者（以 userID 标识）的视频数据
/// @ warning pixelBuffer必须在用完之后手动释放，否则会引起内存泄漏
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session  didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer ofUserID:(NSString *)userID;

/// @abstract 连麦时，对方（以 userID 标识）取消视频的数据回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didLostPixelBufferOfUserID:(NSString *)userID;

/*!
 *  @abstract 连麦时，连麦用户（以 userID 标识）音量监测回调
 *
 * @param inputLevel 本地语音输入音量
 *
 * @param outputLevel 本地语音输出音量
 *
 * @param rtcActiveStreams 其他连麦用户的语音音量对应表，以userID为key，对应音量为值，只包含音量大于0的用户
 *
 * @discussion 音量对应幅度：0-9，其中0为无音量，9为最大音量
 *
 * @see rtcMonitorAudioLevel开启当前回调
 */
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session audioLocalInputLevel:(NSInteger)inputLevel localOutputLevel:(NSInteger)outputLevel otherRtcActiveStreams:(NSDictionary *)rtcActiveStreams;

@end

#pragma mark - basic

/*!
 * @abstract 推流中的核心类。
 *
 * @discussion 一个 PLMediaStreamingSession 实例会包含了对视频源、音频源的控制，并且对流的操作及流状态的返回都是通过它来完成的。
 */
@interface PLMediaStreamingSession : NSObject

@property (nonatomic, assign, readonly) BOOL    isStreamingRunning;

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
@property (nonatomic, strong, readonly) UIView *previewView;

/// 代理对象
@property (nonatomic, weak) id<PLMediaStreamingSessionDelegate> delegate;

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
 * @return PLCameraStreamingSession 实例
 *
 * @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式，当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式，当videoStreamingConfiguration 和 audioStreamingConfiguration 同时为 nil 时为纯连麦模式。当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。
 */
- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream NS_DESIGNATED_INITIALIZER;
  
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
 * @param dns dnsmanager，自定义 dns 查询，使用 HappyDNS
 *
 * @return PLCameraStreamingSession 实例
 *
 * @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式，当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式，当videoStreamingConfiguration 和 audioStreamingConfiguration 同时为 nil 时为纯连麦模式。当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。PLMediaStreamingSession 对象默认会使用 HappyDNS 做 dns 解析，如果你期望自己配置 dns 解析的规则，可以通过传递自己定义的 dns manager 来做 dns 查询。如果你对 dns 解析部分不清楚，可以直接使用 
    -initWithVideoCaptureConfiguration:audioCaptureConfiguration:videoStreamingConfiguration:audioStreamingConfiguration:stream 来初始化 PLCameraStreamingSession 对象
 */
- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream
                                              dns:(QNDnsManager *)dns;

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
 * @param dns dnsmanager，自定义 dns 查询，使用 HappyDNS
 *
 * @param eaglContext 外部 EAGLContext 对象，用做画面预览视图的 context
 *
 * @return PLCameraStreamingSession 实例
 *
 * @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式，当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式，当videoStreamingConfiguration 和 audioStreamingConfiguration 同时为 nil 时为纯连麦模式。当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。PLMediaStreamingSession 对象默认会使用 HappyDNS 做 dns 解析，如果你期望自己配置 dns 解析的规则，可以通过传递自己定义的 dns manager 来做 dns 查询。如果你对 dns 解析部分不清楚，可以直接使用
 -initWithVideoCaptureConfiguration:audioCaptureConfiguration:videoStreamingConfiguration:audioStreamingConfiguration:stream 来初始化 PLCameraStreamingSession 对象
 */
- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream
                                              dns:(QNDnsManager *)dns
                                      eaglContext:(EAGLContext *)eaglContext;

/*!
 * 销毁 session 的方法
 *
 * @discussion 销毁 StreamingSession 的方法，销毁前不需要调用 stop 方法。
 */

- (void)destroy;

@end


#pragma mark - Category (PLStreamingKit)

@interface PLMediaStreamingSession (PLStreamingKit)

/// 流的状态，只读属性
@property (nonatomic, assign, readonly) PLStreamState   streamState;

/// 流对象
@property (nonatomic, strong) PLStream   *stream;

@property (nonatomic, copy) NSURL *pushURL;

/// 默认为 3s，可设置范围为 [1..30] 秒
@property (nonatomic, assign) NSTimeInterval    statusUpdateInterval;

/// [0..1], 不可超出这个范围, 默认为 0.5
@property (nonatomic, assign) CGFloat threshold;

/// Buffer 最多可包含的包数，默认为 300
@property (nonatomic, assign) NSUInteger    maxCount;
@property (nonatomic, assign, readonly) NSUInteger    currentCount;

/*!
 @property   receiveTimeout
 @abstract   网络连接和接收数据超时。
 
 @discussion 以秒作为单位。默认为 15s, 设定最小数值不得低于 3s，否则不变更。
 
 @see        sendTimeout
 
 @since      v1.1.4
 */
@property (nonatomic, assign) int   receiveTimeout;

/*!
 @property   sendTimeout
 @abstract   网络发送数据超时。
 
 @discussion 以秒作为单位。默认为 3s, 设定最小数值不得低于 3s，否则不变更。
 
 @see        receiveTimeout
 
 @since      v1.1.4
 */
@property (nonatomic, assign) int   sendTimeout;

/*!
 @property   dynamicFrameEnable
 @abstract   开启动态帧率功能，自动调整的最大帧率不超过 videoStreamingConfiguration.expectedSourceVideoFrameRate。该功能默认为关闭状态。
 */
@property (nonatomic,assign, getter=isDynamicFrameEnable) BOOL dynamicFrameEnable;

/*!
 @property   monitorNetworkStateEnable
 @abstract   开启网络切换监测，默认处于关闭状态
 
 @discussion 打开该开关后，需实现回调函数 connectionChangeActionCallback，以完成在某种网络切换状态下对推流连接的处理判断。
 @see        connectionChangeActionCallback
 */
@property (nonatomic, assign, getter=isMonitorNetworkStateEnable) BOOL monitorNetworkStateEnable;

/*!
 @property   autoReconnectEnable
 @abstract   自动断线重连开关，默认关闭。
 
 @discussion 该方法在推流 SDK 内部实现断线自动重连。若开启此机制，则当推流因异常导致中断时，-mediaStreamingSession:didDisconnectWithError:回调不会马上被触发，推流将进行最多三次自动重连，每次重连的等待时间会由初次的 0~2s 递增至最大 10s。等待重连期间，推流状态 streamState 会变为 PLStreamStateAutoReconnecting。一旦三次自动重连仍无法成功连接，则放弃治疗，-mediaStreamingSession:didDisconnectWithError:回调将被触发。
 该机制默认关闭，用户可在 -mediaStreamingSession:didDisconnectWithError: 方法中自定义添加断线重连处理逻辑。
 @see        connectionInterruptionHandler
 */
@property (nonatomic, assign, getter=isAutoReconnectEnable) BOOL autoReconnectEnable;

/*!
 @method     enableAdaptiveBitrateControlWithMinVideoBitRate:
 @abstract   开启自适应码率调节功能
 
 @param      minVideoBitRate 最小平均码率
 
 @discussion 该方法在推流 SDK 内部实现动态码率调节。开启该机制时，需设置允许调节的最低码率，以便使自动调整后的码率不会低于该范围。该机制根据网络吞吐量来调节推流的码率，在网络带宽变小导致发送缓冲区数据持续增长时，SDK 内部将适当降低推流码率，若情况得不到改善，则会重复该过程直至平均码率降至用户设置的最低值；反之，当一段时间内网络带宽充裕，SDK 将适当增加推流码率，直至达到预设的推流码率。
 自适应码率机制默认关闭，用户可利用 -mediaStreamingSession:streamStatusDidUpdate 回调数据实现自定义版本的码率调节功能。
 */
- (void)enableAdaptiveBitrateControlWithMinVideoBitRate:(NSUInteger)minVideoBitRate;

/*!
 @method     disableAdaptiveBitrateControl
 @abstract   关闭自适应码率调节功能，默认即为关闭状态
 */
- (void)disableAdaptiveBitrateControl;

/*!
 @property   connectionInterruptionHandler
 @abstract   推流断开用户回调
 
 @discussion 该回调函数传入参数为推流断开产生的错误信息 error。返回值为布尔值，YES 表示在该错误状态下允许推流自动重连，NO 则代表不允许自动重连。本回调函数与 autoReconnectEnable 开关配合作用，只有在该开关开启时，本回调会在自动重连之前被调用，并通过返回值判断是否继续自动重连。若用户未设置该回调方法，则按默认策略最多进行三次自动重连。
 
 @warning    该回调会在主线程中执行
 
 @see        autoReconnectEnable
 */
@property (nonatomic, copy) ConnectionInterruptionHandler connectionInterruptionHandler;

/*!
 @property   connectionChangeActionCallback
 @abstract   网络切换用户回调
 
 @discussion 该回调函数与 monitorNetworkStateEnable 开关配合作用，只有将该开关开启时，该回调才会执行。该回调函数传入参数为当前网络的切换状态 PLNetworkStateTransition。返回值为布尔值，YES 表示在某种切换状态下允许推流自动重启，NO 则代表该状态下不应自动重启。该回调与自动重连回调 connectionInterruptionHandler 的区别在于，当推流网络从 WWAN 切换到 WiFi 时，推流不会被断开而继续使用 WWAN，此时自动重连机制不会被触发，SDK 内部会调用 connectionChangeActionCallback 来判断是否需要重启推流以使用优先级更高的网络。值得注意的是，在开启自动重连开关 autoReconnectEnable，并实现了本回调的情况下，推流时网络从 WiFi 切换到 WWAN，SDK 将优先执行本回调函数判断是否主动重启推流。如果用户选择在此情况下不主动重启，则等推流连接超时后将自动重连决定权交予 connectionInterruptionHandler 判断。如果两个回调均未被实现，则该情况下会默认断开推流以防止用户流量消耗。
 
 @warning    该回调会在主线程中执行
 
 @see        monitorNetworkStateEnable
 @see        connectionInterruptionHandler
 */
@property (nonatomic, copy) ConnectionChangeActionCallback connectionChangeActionCallback;

/*!
 @property   quicEnable
 @abstract   使用 QUIC 协议推流，默认处于关闭状态

 @discussion 打开该开关后，将使用 QUIC 协议推流，弱网下有更好的效果。

 @warning   请在开始推流前设置，推流过程中设置该值不会影响当次推流的行为。
 @warning   使用 QUIC 协议推流到不支持 QUIC 的 CDN 会失败。

 @since      @v2.3.0
 */
@property (nonatomic, assign, getter=isQuicEnable) BOOL quicEnable;

/*!
 @method     startStreamingWithFeedback:
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
- (void)startStreamingWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

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
- (void)startStreamingWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

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
- (void)restartStreamingWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

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
- (void)restartStreamingWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 * 结束推流
 */
- (void)stopStreaming;

/**
 @brief 重新加载视频推流配置
 
 @param videoStreamingConfiguration 新的视频编码配置
 */
- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration;

/**
 *  人工报障
 *
 *  @discussion 在出现特别卡顿的时候，可以调用此方法，上报故障。
 *
 */
- (void)postDiagnosisWithCompletionHandler:(nullable PLStreamDiagnosisResultHandler)handle;

@end

#pragma mark - Category (CameraSource)

/*!
 * @category PLCameraStreamingSession(CameraSource)
 *
 * @discussion 与摄像头相关的接口
 */
@interface PLMediaStreamingSession (CameraSource)

/*!
 @property   captureSession
 @abstract   视频采集 session，只读变量，给有特殊需求的开发者使用，最好不要修改
 
 @since      v2.3.2
 */
@property (nonatomic, readonly) AVCaptureSession * _Nullable captureSession;

/*!
 @property   videoCaptureDeviceInput
 @abstract   视频采集输入源，只读变量，给有特殊需求的开发者使用，最好不要修改
 
 @since      v2.3.2
 */
@property (nonatomic, readonly) AVCaptureDeviceInput * _Nullable videoCaptureDeviceInput;

/// default as AVCaptureDevicePositionBack.
@property (nonatomic, assign) AVCaptureDevicePosition   captureDevicePosition;

/**
 @brief 开启 camera 时的采集摄像头的旋转方向，默认为 AVCaptureVideoOrientationPortrait
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/// default as NO.
@property (nonatomic, assign, getter=isTorchOn) BOOL    torchOn;

/*!
 @property  continuousAutofocusEnable
 @abstract  连续自动对焦。该属性默认开启。
 */
@property (nonatomic, assign, getter=isContinuousAutofocusEnable) BOOL  continuousAutofocusEnable;

/*!
 @property  touchToFocusEnable
 @abstract  手动点击屏幕进行对焦。该属性默认开启。
 */
@property (nonatomic, assign, getter=isTouchToFocusEnable) BOOL touchToFocusEnable;

/*!
 @property  smoothAutoFocusEnabled
 @abstract  该属性适用于视频拍摄过程中用来减缓因自动对焦产生的镜头伸缩，使画面不因快速的对焦而产生抖动感。该属性默认开启。
 */
@property (nonatomic, assign, getter=isSmoothAutoFocusEnabled) BOOL  smoothAutoFocusEnabled;

/// default as (0.5, 0.5), (0,0) is top-left, (1,1) is bottom-right.
@property (nonatomic, assign) CGPoint   focusPointOfInterest;

/// 默认为 1.0，设置的数值需要小于等于 videoActiveForat.videoMaxZoomFactor，如果大于会设置失败。
@property (nonatomic, assign) CGFloat videoZoomFactor;

@property (nonatomic, strong, readonly) NSArray<AVCaptureDeviceFormat *> *videoFormats;

@property (nonatomic, strong) AVCaptureDeviceFormat *videoActiveFormat;

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

/**
 *  推流预览的渲染队列
 */
@property (nonatomic, strong, readonly) dispatch_queue_t renderQueue;

/**
 *  推流预览的渲染 OpenGL context
 */
@property (nonatomic, strong, readonly) EAGLContext *renderContext;

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
- (void)getScreenshotWithCompletionHandler:(nullable PLStreamScreenshotHandler)handler;

/**
 *  @brief 设置推流图片
 *
 *  @param image 推流的图片
 *
 *  @discussion 由于某些特殊原因不想使用摄像头采集的数据来推流时，可以使用该接口设置一张图片来替代。传入 nil 则关闭该功能。
 *
 *  @warning 请确保传入的 image 的宽和高是 16 的整数倍。请勿在 applicationState 为 UIApplicationStateBackground 时调用该接口，否则将出错。
 *
 *  @since v2.2.1
 */
- (void)setPushImage:(nullable UIImage *)image;

@end

#pragma mark - Category (OverlayView)

/*!
 * @category PLMediaStreamingSession(OverlayView)
 *
 * @discussion 与贴纸、文字相关的接口
 */
@interface PLMediaStreamingSession (OverlayView)

/*!
 * @brief 贴纸、文字的父视图
 
 *  @since v2.3.2
 */
@property (nonatomic, strong, readonly) UIView * _Nonnull overlaySuperView;

/**
 * @brief 将 view 添加到 overlaySuperView 上。
 *
 * @param view 要添加的视图
 
 *  @since v2.3.2
 */
- (void)addOverlayView:(UIView * _Nullable )view;

/**
 * @brief 刷新 overlaySuperView 上的 view 视图。
 *
 * @param view 要刷新的视图
 
 *  @since v2.3.2
 */
- (void)refreshOverlayView:(UIView * _Nullable)view;

/**
 * @brief 将 view 从 overlaySuperView 上移除。
 *
 * @param view 要移除的视图
 
 *  @since v2.3.2
 */
- (void)removeOverlayView:(UIView * _Nullable)view;

/**
 * @brief 将 overlaySuperView 上的所有子视图 view 移除。
 
 *  @since v2.3.2
 */
- (void)removeAllOverlayViews;

@end

#pragma mark - Category (MicrophoneSource)

/*!
 * @category PLCameraStreamingSession(MicrophoneSource)
 *
 * @discussion 与麦克风相关的接口
 */
@interface PLMediaStreamingSession (MicrophoneSource)

/*!
 * @brief 返听功能
 */
@property (nonatomic, assign, getter=isPlayback) BOOL   playback;

@property (nonatomic, assign, getter=isMuted)   BOOL    muted;                   // default as NO.

/*!
   @brief 是否允许在后台与其他 App 的音频混音而不被打断，默认关闭。
 */
@property (nonatomic, assign) BOOL allowAudioMixWithOthers;

/*!
   @brief 音频被其他 app 中断开始时会回调该函数，注意回调不在主线程进行。
 */
@property (nonatomic, copy) PLAudioSessionDidBeginInterruptionCallback _Nullable audioSessionBeginInterruptionCallback;

/*!
   @brief 音频中断结束时回调，即其他 app 结束打断音频操作时会回调该函数，注意回调不在主线程进行。
 */
@property (nonatomic, copy) PLAudioSessionDidEndInterruptionCallback _Nullable audioSessionEndInterruptionCallback;

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
 * @category PLMediaStreamingSession(Application)
 *
 * @discussion 与系统相关的接口
 */
@interface PLMediaStreamingSession (Application)

@property (nonatomic, assign, getter=isIdleTimerDisable) BOOL  idleTimerDisable;   // default as YES.

@end

#pragma mark - Category (Authorization)

/*!
 * @category PLMediaStreamingSession(Authorization)
 *
 * @discussion 与设备授权相关的接口
 */
@interface PLMediaStreamingSession (Authorization)

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

#pragma mark - Category (RTC)

/**
 @brief PLMediaStreamingKit(RTC) 集合了 RTC 相关的一系列接口，要调用此分类的接口请确保工程中已经引入了 PLMediaStreamingKit(RTC).a，如果没有引入该静态库，调用该分类的接口会导致程序抛 exception
 */
@interface PLMediaStreamingSession (RTC)

/**
 @abstract 此属性表示连麦是否处于运行的状态
 
 @warning 要调用此接口请确保工程中已经引入了 PLMediaStreamingKit（RTC）.a，如果没有引入该静态库，调用该接口会导致程序抛 exception
 */
@property (nonatomic, assign, readonly) BOOL    isRtcRunning;

/**
 @abstract 连麦的状态，只读属性
 */
@property (nonatomic, assign, readonly) PLRTCState   rtcState;

/**
 @abstract 连麦房间中的 userID 列表（不包含自己），只读
 */
@property (nonatomic, strong, readonly) NSArray *rtcParticipants;

/**
 @abstract 连麦房间中的人数（不包含自己），只读
 */
@property (nonatomic, assign, readonly) NSUInteger rtcParticipantsCount;

/**
 @abstract 配置合流后连麦的窗口在主窗口中的位置和大小，里面存放 NSValue 封装的 CGRect。注意，该位置是指连麦的窗口在推出来流的画面中的位置，并非在本地预览的位置
 
 @see - (void)RTCStreamingSession:(PLRTCStreamingSession *)session userID:(NSString *)userID didAttachRemoteView:(UIView *)remoteView;
 
 @see - (void)RTCStreamingSession:(PLRTCStreamingSession *)session userID:(NSString *)userID didDetachRemoteView:(UIView *)remoteView;
 
 @warning - 目前版本需要在连麦开始前设置好，连麦过程中更新无效
 */
@property (nonatomic, strong) NSArray *rtcMixOverlayRectArray;

/**
 @abstract 设置连麦视频动态码率调整的范围的下限(单位：bps)，当上下限相等时，码率固定，将不会动态调整。
 */
@property (nonatomic, assign) NSUInteger rtcMinVideoBitrate;

/**
 @abstract 设置连麦视频动态码率调整的范围的上限(单位：bps)，当上下限相等时，码率固定，将不会动态调整
 */
@property (nonatomic, assign) NSUInteger rtcMaxVideoBitrate;

/**
 @abstract 设置连麦窗口的大小，请在 joinRoom 前设置。由于主播涉及到画面合成和推流，可不设置或者设置较大 size，其它连麦者可以设置较小 size。
 */
@property (nonatomic, strong) NSDictionary *rtcOption;

/**
 @abstract 设置是否播放房间内其他连麦者音频，默认是 NO，为 YES 时，其他连麦者音频静默
 */
@property (nonatomic, assign, getter=isMuteSpeaker) BOOL muteSpeaker;

/**
 @abstract  设置连麦是否开启连麦音频监测回调，默认是 NO，为 YES 时，开启房间连麦音频音量回调
  */
@property (nonatomic, assign, getter=isRtcMonitorAudioLevel) BOOL rtcMonitorAudioLevel;

/// @abstract 设置是否静音，默认是 NO，为 YES 时，连麦静音，推流的音频自己的声音静音，其它连麦者的声音正常
/// @see muted
/// @warning 请勿与 muted 同时使用，否则可能出现状态错乱
@property (nonatomic, assign, getter=isMuteMicrophone) BOOL muteMicrophone;



/*!
 * 开始连麦
 *
 * @param stream Stream 对象
 *
 * @param roomID 连麦的房间名
 *
 * @param userID 连麦的的用户 ID，需要保证在同一房间的不同用户 ID 是不同的
 *
 * @param roomToken 连麦房间的 roomToken
 *
 * @param roomToken 连麦房间的 roomToken
 *
 * @param rtcConfiguration 连麦相关的配置项
 *
 * @discussion 开始连麦后，音视频会发布到房间中，同时拉取房间中的音视频流。可通过 PLMediaStreamingSessionDelegate 的回调得到连麦的状态及对方的 View。
 */
- (void)startConferenceWithRoomName:(NSString *)roomName
                             userID:(NSString *)userID
                          roomToken:(NSString *)roomToken
                   rtcConfiguration:(PLRTCConfiguration *)rtcConfiguration;

/*!
 * 结束连麦
 *
 * @discussion 结束连麦后，会停止推送本地音视频流，同时停止拉取房间中的音视频流。可通过 PLMediaStreamingSessionDelegate 得到连麦的状态及取消渲染对方的 View。
 *
 */
- (void)stopConference;

/*!
 * 踢出指定 userID 的用户
 *
 * @discussion 踢出指定 userID 的用户，只有主播才有踢人的权限。
 */
- (void)kickoutUserID:(NSString *)userID;

@end

#pragma mark - Category (Info)

/*!
 * @category PLCameraStreamingSession(Info)
 *
 * @discussion sdk 相关信息
 */
@interface PLMediaStreamingSession (Info)

/*!
 @method     versionInfo
 @abstract   PLCameraStreamingKit 的 SDK 版本。
 
 @since      v1.8.1
 */
+ (NSString *)versionInfo;

@end

