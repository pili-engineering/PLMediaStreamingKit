//
//  PLRTCStreamingSession.h
//  PLRTCStreamingKit
//
//  Created by lawder on 16/7/8.
//  Copyright © 2016年 PILI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PLCommon.h"
#import "PLStreamingSession.h"

@class PLRTCStreamingSession;
@class QNDnsManager;
@class PLRTCConfiguration;

/// @abstract delegate 对象可以实现对应的方法来获取推流及连麦的状态。除特别说明外，会在 delegateQueue 中回调，如未设置 delegateQueue，将在主队列中回调
@protocol PLRTCStreamingSessionDelegate <NSObject>

@optional

/// @abstract 推流状态已变更的回调
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session streamStateDidChange:(PLStreamState)state;

/// @abstract 因产生了某个 error 的回调，，error 错误码的含义可以查看 PLTypeDefines.h 文件
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session didDisconnectWithError:(NSError *)error;

- (void)RTCStreamingSession:(PLRTCStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status;


/// @abstract 连麦状态已变更的回调
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session rtcStateDidChange:(PLRTCState)state;

/// @abstract 因产生了某个 error 的回调，，error 错误码的含义可以查看 PLTypeDefines.h 文件
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session rtcDidFailWithError:(NSError *)error;

/// @abstract 连麦时，将对方（以 userID 标识）的视频渲染到 remoteView 后的回调，可将 remoteView 添加到合适的 View 上将其显示出来。本接口在主队列中回调。
/// @warning 推出来的流中连麦的窗口位置在 rtcMixOverlayRectArray 中设定，与 remoteView 的位置没有关系。
/// @see mixOverlayRectArray
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session userID:(NSString *)userID didAttachRemoteView:(UIView *)remoteView;

/// @abstract 连麦时，取消对方（以 userID 标识）的视频渲染到 remoteView 后的回调，可在该方法中将 remoteView 从父 View 中移除。本接口在主队列中回调。
/// @warning 推出来的流中连麦的窗口位置在 rtcMixOverlayRectArray 中设定，与 remoteView 的位置没有关系。
/// @see mixOverlayRectArray
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session userID:(NSString *)userID didDetachRemoteView:(UIView *)remoteView;

/// @abstract 被 userID 从房间踢出
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session didKickoutByUserID:(NSString *)userID;

/// @abstract  userID 加入房间
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session didJoinConferenceOfUserID:(NSString *)userID;

/// @abstract userID 离开房间
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session didLeaveConferenceOfUserID:(NSString *)userID;

/// @abstract 连麦时，SDK 内部渲染连麦者（以 userID 标识）的视频数据
/// @ warning pixelBuffer必须在用完之后手动释放，否则会引起内存泄漏
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session  didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer ofUserID:(NSString *)userID;

/// @abstract 连麦时，对方（以 userID 标识）取消视频的数据回调
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session didLostPixelBufferOfUserID:(NSString *)userID;

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
- (void)RTCStreamingSession:(PLRTCStreamingSession *)session audioLocalInputLevel:(NSInteger)inputLevel localOutputLevel:(NSInteger)outputLevel otherRtcActiveStreams:(NSDictionary *)rtcActiveStreams;

@end

@interface PLRTCStreamingSession : NSObject

/// @abstract 视频编码及推流配置，只读
@property (nonatomic, strong, readonly) PLVideoStreamingConfiguration  *videoStreamingConfiguration;

/// @abstract 音频编码及推流配置，只读
@property (nonatomic, strong, readonly) PLAudioStreamingConfiguration  *audioStreamingConfiguration;

/// @abstract 流对象
@property (nonatomic, strong) PLStream   *stream;

@property (nonatomic, copy) NSURL *pushURL;

/// @abstract 代理对象
@property (nonatomic, weak) id<PLRTCStreamingSessionDelegate> delegate;

/// @abstract 代理回调的队列
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

/// @abstract 流的状态，只读属性
@property (nonatomic, assign, readonly) PLStreamState   streamState;

@property (nonatomic, assign, readonly) BOOL    isStreamingRunning;

/// @abstract 默认为 3s，可设置范围为 [1..30] 秒
@property (nonatomic, assign) NSTimeInterval    statusUpdateInterval;

/// @abstract 设置是否静音，默认是 NO，为 YES 时，连麦及推流均处于静音状态
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/// @abstract 设置是否播放房间内其他连麦者音频，默认是 NO，为 YES 时，其他连麦者音频静默
@property (nonatomic, assign, getter=isMuteSpeaker) BOOL muteSpeaker;

/// @abstract  设置连麦是否开启连麦音频监测回调，默认是 NO，为 YES 时，开启房间连麦音频音量回调
@property (nonatomic, assign, getter=isRtcMonitorAudioLevel) BOOL rtcMonitorAudioLevel;

/// @abstract 设置是否静音，默认是 NO，为 YES 时，连麦静音，推流的音频自己的声音静音，其它连麦者的声音正常
/// @see muted
/// @warning 请勿与 muted 同时使用，否则可能出现状态错乱
@property (nonatomic, assign, getter=isMuteMicrophone) BOOL muteMicrophone;




/*!
 * 初始化方法
 *
 * @param videoStreamingConfiguration 视频编码及推流的配置信息
 *
 * @param audioStreamingConfiguration 音频编码及推流的配置信息
 *
 * @return PLRTCStreamingSession 实例
 *
 * @discussion 不需要推流时 videoStreamingConfiguration、audioStreamingConfiguration、stream 可以传入 nil。
 */
- (instancetype)initWithVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                        audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                             stream:(PLStream *)stream;


- (instancetype)initWithVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                        audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                             stream:(PLStream *)stream
                                                dns:(QNDnsManager *)dns;

/*!
 * 销毁对象
 *
 * @discussion 释放相关资源。
 */
- (void)destroy;

- (void)startStreamingWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

- (void)startStreamingWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

- (void)restartStreamingWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

- (void)restartStreamingWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

- (void)stopStreaming;

- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration;

- (void)reloadAudioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration;

/*!
 @method     pushPixelBuffer:completion:
 @abstract   发送视频 CVPixelBufferRef 数据。
 
 @param      pixelBuffer 待发送的 CVPixelBufferRef 数据
 @param      handler 在编码 pixelBuffer 数据完成时的回调 block
 
 @discussion 如果你期望在调用完该方法后还要对 pixelBuffer 做操作，请调用该方法，并在 handler block 中完成操作。
 
 @warning    该方法的 handler 回调并不在主线程，也不在 delegateQueue 线程，所以除了对 pixelBuffer 做 unlock 或者销毁等操作，务必不要做额外高计算量的操作，或者长时间让 handler 无法结束运行。
 受连麦接口所限，目前仅支持 kCVPixelFormatType_420YpCbCr8BiPlanarFullRange 格式的 pixelBuffer 数据
 */
- (void)pushPixelBuffer:(CVPixelBufferRef)pixelBuffer completion:(void (^)(BOOL success))handler;

/*!
 @method     pushAudioBuffer:asbd:completion:
 @abstract   发送音频 AudioBuffer 数据。
 
 @param      audioBuffer 待发送的音频 AudioBuffer 数据
 @param      asbd 待发送 AudioBuffer 对应的 AudioStreamBasicDescription
 @param      handler 在编码 AudioBuffer 数据完成时的回调 block, 带是否编码成功的参数 success
 
 @discussion 如果你期望在调用完该方法后还要对 AudioBuffer 做操作，请调用该方法
 
 @warning    该方法的 handler 回调并不在主线程，也不在 delegateQueue 线程，所以除了对 AudioBuffer 做 unlock 或者销毁等操作，务必不要做额外高计算量的操作，或者长时间让 handler 无法结束运行。
 */
- (void)pushAudioBuffer:(AudioBuffer *)audioBuffer asbd:(const AudioStreamBasicDescription *)asbd completion:(void (^)(BOOL success))handler;

/**
 *  截图
 *  @param handle 类型 PLStreamScreenshotHandler block 。
 *
 *  @discussion 截图操作为异步，完成后将通过 handler 回调返回 UIImage 类型图片数据。
 *
 *  @since v2.2.0
 *
 */
- (void)getScreenshotWithCompletionHandler:(nullable PLStreamScreenshotHandler)handler;

@end

@interface PLRTCStreamingSession (Network)

/*!
 @property   receiveTimeout
 @abstract   网络连接和接收数据超时。
 
 @discussion 以秒作为单位。默认为 15s, 设定最小数值不得低于 3s，否则不变更。
 
 @see        sendTimeout
 
 */
@property (nonatomic, assign) int   receiveTimeout;

/*!
 @property   sendTimeout
 @abstract   网络发送数据超时。
 
 @discussion 以秒作为单位。默认为 3s, 设定最小数值不得低于 3s，否则不变更。
 
 @see        receiveTimeout
 
 */
@property (nonatomic, assign) int   sendTimeout;

/*!
 @property   autoReconnectEnable
 @abstract   自动断线重连开关，默认关闭。
 
 @discussion 该方法在推流SDK内部实现断线自动重连。若开启此机制，则当推流因异常导致中断时，-streamingSession:didDisconnectWithError:回调不会马上被触发，推流将进行最多三次自动重连，每次重连的等待时间会由初次的0~2s递增至最大10s。等待重连期间，推流状态 streamState 会变为 PLStreamStateAutoReconnecting。一旦三次自动重连仍无法成功连接，则放弃治疗，-streamingSession:didDisconnectWithError:回调将被触发。
 该机制默认关闭，用户可在 -streamingSession:didDisconnectWithError: 方法中自定义添加断线重连处理逻辑。
 @see        connectionInterruptionHandler
 */
@property (nonatomic, assign, getter=isAutoReconnectEnable) BOOL autoReconnectEnable;

/*!
 @method     enableAdaptiveBitrateControlWithMinVideoBitRate:
 @abstract   开启自适应码率调节功能
 
 @param      minVideoBitRate 最小平均码率
 
 @discussion 该方法在推流SDK内部实现动态码率调节。开启该机制时，需设置允许调节的最低码率，以便使自动调整后的码率不会低于该范围。该机制根据网络吞吐量来调节推流的码率，在网络带宽变小导致发送缓冲区数据持续增长时，SDK内部将适当降低推流码率，若情况得不到改善，则会重复该过程直至平均码率降至用户设置的最低值；反之，当一段时间内网络带宽充裕，SDK将适当增加推流码率，直至达到预设的推流码率。
 自适应码率机制默认关闭，用户可利用 -streamingSession:streamStatusDidUpdate 回调数据实现自定义版本的码率调节功能。
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
 
 @discussion 该回调函数传入参数为推流断开产生的错误信息 error。返回值为布尔值，YES表示在该错误状态下允许推流自动重连，NO则代表不允许自动重连。本回调函数与 autoReconnectEnable 开关配合作用，只有在该开关开启时，本回调会在自动重连之前被调用，并通过返回值判断是否继续自动重连。若用户未设置该回调方法，则按默认策略最多进行三次自动重连。
 
 @warning    该回调会在主线程中执行
 
 @see        autoReconnectEnable
 */
@property (nonatomic, copy) ConnectionInterruptionHandler connectionInterruptionHandler;

/*!
 @property   connectionChangeActionCallback
 @abstract   网络切换用户回调
 
 @discussion 该回调函数传入参数为当前网络的切换状态 PLNetworkStateTransition。 返回值为布尔值，YES表示在某种切换状态下允许推流自动重启，NO则代表该状态下不应自动重启。该回调自动重连回调 connectionInterruptionHandler 的区别在于，当推流网络从WWAN切换到WiFi时，推流不会被断开而继续使用WWAN，此时自动重连机制不会被触发，SDK内部会调用 connectionChangeActionCallback 来判断是否需要重启推流以使用优先级更高的网络。
 值得注意的是，在开启自动重连开关 autoReconnectEnable，并实现了本回调的情况下，推流时网络从WiFi切换到WWAN，SDK将优先执行本回调函数判断是否主动重启推流。如果用户选择在此情况下不主动重启，则等推流连接超时后将自动重连决定权交予 connectionInterruptionHandler 判断。如果两个回调均未被实现，则该情况下会默认断开推流以防止用户流量消耗。
 
 @warning    该回调会在主线程中执行
 
 @see        autoReconnectEnable
 @see        connectionInterruptionHandler
 */
@property (nonatomic, copy) ConnectionChangeActionCallback connectionChangeActionCallback;

/*!
 @property   dynamicFrameEnable
 @abstract   开启动态帧率功能，自动调整的最大帧率不超过 videoStreamingConfiguration.expectedSourceVideoFrameRate。该功能默认为关闭状态。
 */
@property (nonatomic, assign, getter=isDynamicFrameEnable) BOOL dynamicFrameEnable;

@property (nonatomic, assign, getter=isMonitorNetworkStateEnable) BOOL monitorNetworkStateEnable;

/*!
 @property   quicEnable
 @abstract   使用 QUIC 协议推流，默认处于关闭状态

 @discussion 打开该开关后，将使用 QUIC 协议推流，弱网下有更好的效果。

 @warning   请在开始推流前设置，推流过程中设置该值不会影响当次推流的行为。
 @warning   使用 QUIC 协议推流到不支持 QUIC 的 CDN 会失败。

 @since      @v2.3.0
 */
@property (nonatomic, assign, getter=isQuicEnable) BOOL quicEnable;

/**
 *  人工报障
 *
 *  @discussion 在出现特别卡顿的时候，可以调用此方法，上报故障。
 *
 */
- (void)postDiagnosisWithCompletionHandler:(nullable PLStreamDiagnosisResultHandler)handle;


@end

/*!
 @category   PLRTCStreamingSession (SendingBuffer)
 @abstract   PLRTCStreamingSession 发送队列相关参数
 
 */
@interface PLRTCStreamingSession (SendingBuffer)

/*!
 @property   threshold
 @abstract   发送丢列触发丢包策略时会丢掉的阈值。
 
 @discussion 当队列满时，会触发发送队列内的包被丢弃，即丢帧。此时需要一个边界来停止丢帧行为，就是这个阈值字段。
 可设定范围 [0..1], 不可超出这个范围, 默认为 0.5。
 
 */
@property (nonatomic, assign) CGFloat   threshold;

/*!
 @property   maxCount
 @abstract   发送队列最大容纳包数量。
 
 @discussion 该数量囊括音频与视频包，默认为 300 个。当网络不佳时，发送队列就可能出现队列满的情况，此时会触发队列丢包。
 
 */
@property (nonatomic, assign) NSUInteger    maxCount;

/*!
 @property   currentCount
 @abstract   发送队列当前已有包数，只读属性。
 
 */
@property (nonatomic, assign, readonly) NSUInteger    currentCount;

@end

#pragma mark - Category (Processing)

/*!
 @category   PLRTCStreamingSession (Processing)
 @abstract   PLRTCStreamingSession 数据处理相关接口
 
 @since      v2.1.2
 */
@interface PLRTCStreamingSession (Processing)

/*!
 @property   denoiseOn
 @abstract   是否开启降噪功能。
 
 @see        v2.1.2
 */
@property (nonatomic, assign, getter=isDenoiseOn) BOOL denoiseOn;

@end

#pragma mark - Categroy (Application)

///------------------
/// @name 应用状态管理
///------------------

/*!
 @category   PLCameraStreamingSession(Application)
 @abstract   与应用状态相关的接口
 
 */
@interface PLRTCStreamingSession (Application)

/*!
 @property   idleTimerDisable
 @abstract   控制系统屏幕自动锁屏是否关闭。
 
 @discussion 默认为 YES。控制系统屏幕自动锁屏是否关闭。
 
 */
@property (nonatomic, assign, getter=isIdleTimerDisable) BOOL  idleTimerDisable;   // default as YES.

@end

/**
 @brief PLMediaStreamingKit(RTC) 集合了 RTC 相关的一系列接口，要调用此分类的接口请确保工程中已经引入了 PLMediaStreamingKit(RTC).a，如果没有引入该静态库，调用该分类的接口会导致程序抛 exception
 */
@interface PLRTCStreamingSession (RTC)

/**
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
@property (nonatomic, strong, readonly) PLRTCConfiguration *rtcConfiguration;

/**
 @abstract 设置连麦房间的选项，具体选项见: kPLRTCAutoRejoinKey, kPLRTCRejoinTimesKey, kPLRTCConnetTimeoutKey
*/
@property (nonatomic, strong) NSDictionary *rtcOption;

/**
 @abstract 外部传入用于连麦的视频格式
 */
@property (nonatomic, assign) PLRTCVideoFormat rtcVideoFormat;

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
 * @discussion 开始连麦后，音视频会发布到房间中，同时拉取房间中的音视频流。可通过 PLRTCStreamingSessionDelegate 的回调得到连麦的状态及对方的 View。
 */
- (void)startConferenceWithRoomName:(NSString *)roomName
                             userID:(NSString *)userID
                          roomToken:(NSString *)roomToken
                   rtcConfiguration:(PLRTCConfiguration *)rtcConfiguration;

/*!
 * 结束连麦
 *
 * @discussion 结束连麦后，会停止推送本地音视频流，同时停止拉取房间中的音视频流。可通过 PLRTCStreamingSessionDelegate 得到连麦的状态及取消渲染对方的 View。
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

///------------------
/// @name SDK 信息相关
///------------------

/*!
 @category   PLStreamingSession (Info)
 @abstract   SDK 信息相关
 
 @since      v1.1.1
 */
@interface PLRTCStreamingSession (Info)

/*!
 @method     versionInfo
 @abstract   PLStreamingKit 的 SDK 版本。
 
 @since      v1.1.1
 */
+ (NSString *)versionInfo;

@end
