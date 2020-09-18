//
//  PLMediaStreamingSession.h
//  PLCameraStreamingKit
//
//  Created by lawder on 16/7/28.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLStreamingSession.h"

@class PLMediaStreamingSession;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol   PLMediaStreamingSessionDelegate

 @discussion PLMediaStreamingSession 在运行过程中的流状态和事件回调。
*/
@protocol PLMediaStreamingSessionDelegate <NSObject>

@optional

/*!
 @abstract   流状态变更的回调

 @discussion 当状态变为 PLStreamStateAutoReconnecting 时，SDK 会为您自动重连，如果希望停止推流，直接调用 stopStreaming 即可。
*/
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state;

/*!
 @abstract   因产生了某个 error 而断开时的回调

 @discussion error 错误码的含义，可查阅 PLTypeDefines.h 文件
*/
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error;

/*!
 @abstract   流信息更新回调

 @discussion 当开始推流时，默认 statusUpdateInterval 每间隔 3s，调用该回调方法来反馈 3s 内的流状态，包括视频帧率、音频帧率、音视频总码率
*/
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status;

/*!
 @abstract   摄像头授权状态发生变化的回调

 @discussion 建议在初始化配置 PLMediaStreamingSession 前，就使用系统 API 主动发起获取摄像头授权的请求。
*/
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didGetCameraAuthorizationStatus:(PLAuthorizationStatus)status;

/*!
 @abstract   麦克风授权状态发生变化的回调

 @discussion 建议在初始化配置 PLMediaStreamingSession 前，就使用系统 API 主动发起获取麦克风授权的请求。
*/
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didGetMicrophoneAuthorizationStatus:(PLAuthorizationStatus)status;

/*!
 @abstract   获取摄像头原数据时的回调

 @discussion 便于开发者做滤镜等处理，需注意该回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致推流帧率下降。
*/
- (CVPixelBufferRef)mediaStreamingSession:(PLMediaStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer __deprecated_msg("Method deprecated in v2.3.5. Use `mediaStreamingSession:cameraSourceDidGetPixelBuffer:timingInfo:'");

/*!
 @abstract   摄像头原数据时的回调

 @discussion 便于开发者做滤镜等处理，需注意该回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致推流帧率下降。

 @warning    不建议与 mediaStreamingSession:cameraSourceDidGetPixelBuffer: 一同调用；如果一同调用，默认优先使用此方法。

 @since      v2.3.5
*/
- (CVPixelBufferRef __nonnull)mediaStreamingSession:(PLMediaStreamingSession *__nonnull)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer timingInfo:(CMSampleTimingInfo)timingInfo;

/*!
 @abstract   麦克风原数据时的回调

 @discussion 需注意该回调在 AU Remote IO 线程，请不要做过于耗时的操作，否则可能阻塞该线程影响音频输出或其他未知问题。
*/
- (AudioBuffer *)mediaStreamingSession:(PLMediaStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer;

@end

#pragma mark - basic

/*!
 @abstract   推流中的核心类。

 @discussion 一个 PLMediaStreamingSession 实例会包含了对视频源、音频源的控制，并且对流的操作及流状态的返回都是通过它来完成的。
 */
@interface PLMediaStreamingSession : NSObject

/*!
 @abstract 是否在推流中。
*/
@property (nonatomic, assign, readonly) BOOL    isStreamingRunning;

/*!
 @abstract 视频采集配置，只读属性。
*/
@property (nonatomic, copy, readonly) PLVideoCaptureConfiguration *videoCaptureConfiguration;

/*!
 @abstract 音频采集配置，只读属性。
*/
@property (nonatomic, copy, readonly) PLAudioCaptureConfiguration *audioCaptureConfiguration;

/*!
 @abstract 视频编码配置，只读属性。
*/
@property (nonatomic, copy, readonly) PLVideoStreamingConfiguration *videoStreamingConfiguration;

/*!
 @abstract 音频编码配置，只读属性。
*/
@property (nonatomic, copy, readonly) PLAudioStreamingConfiguration *audioStreamingConfiguration;

/*!
 @abstract 摄像头的预览视图，在 PLMediaStreamingSession 初始化之后可以获取该视图
 */
@property (nonatomic, strong, readonly) UIView *previewView;

/*!
 @abstract 代理对象
*/
@property (nonatomic, weak) id<PLMediaStreamingSessionDelegate> delegate;

/*!
 @abstract 代理回调的队列
*/
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

/*!
 @abstract previewView 中视频的填充方式，默认使用 PLVideoFillModePreserveAspectRatioAndFill
*/
@property (nonatomic, assign) PLVideoFillModeType fillMode;

/*!
 @abstract 初始化方法

 @param videoCaptureConfiguration 视频采集的配置信息
 @param audioCaptureConfiguration 音频采集的配置信息
 @param videoStreamingConfiguration 视频编码及推流的配置信息
 @param audioStreamingConfiguration 音频编码及推流的配置信息
 @param stream Stream 对象

 @return PLMediaStreamingSession 实例

 @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式；
             当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式；
             当videoStreamingConfiguration 和 audioStreamingConfiguration 同时为 nil 时为纯连麦模式。
             当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。
 */
- (instancetype)initWithVideoCaptureConfiguration:(nullable PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(nullable PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(nullable PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(nullable PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(nullable PLStream *)stream NS_DESIGNATED_INITIALIZER;
  
/*!
 @abstract 初始化方法

 @param videoCaptureConfiguration   视频采集的配置信息
 @param audioCaptureConfiguration   音频采集的配置信息
 @param videoStreamingConfiguration 视频编码及推流的配置信息
 @param audioStreamingConfiguration 音频编码及推流的配置信息
 @param stream Stream 对象
 @param dns    dnsmanager，自定义 dns 查询，使用 HappyDNS

 @return PLMediaStreamingSession 实例

 @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式；
             当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式；
             当videoStreamingConfiguration 和 audioStreamingConfiguration 同时为 nil 时为纯连麦模式。
             当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。
             PLMediaStreamingSession 对象默认会使用 HappyDNS 做 dns 解析，如果你期望自己配置 dns 解析的规则，可以通过传递自己定义的 dns manager 来做 dns 查询。
             如果你对 dns 解析部分不清楚，可以直接使用
 -initWithVideoCaptureConfiguration:audioCaptureConfiguration:videoStreamingConfiguration:audioStreamingConfiguration:stream 来初始化 PLMediaStreamingSession 对象
 */
- (instancetype)initWithVideoCaptureConfiguration:(nullable PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(nullable PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(nullable PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(nullable PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(nullable PLStream *)stream
                                              dns:(nullable QNDnsManager *)dns;

/*!
 @abstract 初始化方法

 @param videoCaptureConfiguration   视频采集的配置信息
 @param audioCaptureConfiguration   音频采集的配置信息
 @param videoStreamingConfiguration 视频编码及推流的配置信息
 @param audioStreamingConfiguration 音频编码及推流的配置信息
 @param stream Stream 对象
 @param dns    dnsmanager，自定义 dns 查询，使用 HappyDNS
 @param eaglContext 外部 EAGLContext 对象，用做画面预览视图的 context

 @return PLMediaStreamingSession 实例

 @discussion 该方法会检查传入参数，当 videoCaptureConfiguration 或 videoStreamingConfiguration 为 nil 时为纯音频推流模式；
             当 audioCaptureConfiguration 或 audioStreamingConfiguration 为 nil 时为纯视频推流模式；
             当videoStreamingConfiguration 和 audioStreamingConfiguration 同时为 nil 时为纯连麦模式。
             当初始化方法会优先使用后置摄像头，如果发现设备没有后置摄像头，会判断是否有前置摄像头，如果都没有，便会返回 nil。
             PLMediaStreamingSession 对象默认会使用 HappyDNS 做 dns 解析，如果你期望自己配置 dns 解析的规则，可以通过传递自己定义的 dns manager 来做 dns 查询。
             如果你对 dns 解析部分不清楚，可以直接使用
 -initWithVideoCaptureConfiguration:audioCaptureConfiguration:videoStreamingConfiguration:audioStreamingConfiguration:stream 来初始化 PLMediaStreamingSession 对象
 */
- (instancetype)initWithVideoCaptureConfiguration:(nullable PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(nullable PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(nullable PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(nullable PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(nullable PLStream *)stream
                                              dns:(nullable QNDnsManager *)dns
                                      eaglContext:(EAGLContext *)eaglContext;

/*!
 @abstract   销毁 session 的方法

 @discussion 销毁 mediaStreamingSession 的方法，销毁前不需要调用 stop 方法。
 */
- (void)destroy;

@end


#pragma mark - Category (PLStreamingKit)

/*!
 @category   PLMediaStreamingSession(PLStreamingKit)

 @discussion 与 PLStreamingKit 相关的接口
*/
@interface PLMediaStreamingSession (PLStreamingKit)

/*!
 @abstract 流的状态，只读属性。
*/
@property (nonatomic, assign, readonly) PLStreamState streamState;

/*!
 @abstract 流对象。
*/
@property (nonatomic, strong) PLStream *stream;

/*!
 @abstract 推流地址。
*/
@property (nonatomic, copy) NSURL *pushURL;

/*!
 @abstract   流信息更新间隔。

 @discussion 默认为 3s，可设置范围为 [1..30] 秒。
*/
@property (nonatomic, assign) NSTimeInterval statusUpdateInterval;

/*!
 @abstract   流信息更新间隔。

 @discussion 默认为 0.5，可设置范围为 [0..1], 不可超出这个范围。
*/
@property (nonatomic, assign) CGFloat threshold;

/*!
 @abstract   Buffer 最多可包含的包数，默认为 300。
*/
@property (nonatomic, assign) NSUInteger maxCount;

/*!
 @abstract 当前包数量，只读属性。
*/
@property (nonatomic, assign, readonly) NSUInteger currentCount;

/*!
 @abstract   网络连接和接收数据超时。

 @discussion 以秒作为单位。默认为 15s, 设定最小数值不得低于 3s，否则不变更。
*/
@property (nonatomic, assign) int receiveTimeout;

/*!
 @abstract   网络发送数据超时。

 @discussion 以秒作为单位。默认为 3s, 设定最小数值不得低于 3s，否则不变更。
*/
@property (nonatomic, assign) int sendTimeout;

/*!
 @abstract 开启动态帧率功能，自动调整的最大帧率不超过 videoStreamingConfiguration.expectedSourceVideoFrameRate。该功能默认为关闭状态。
*/
@property (nonatomic,assign, getter=isDynamicFrameEnable) BOOL dynamicFrameEnable;

/*!
 @abstract   开启网络切换监测，默认处于关闭状态

 @discussion 打开该开关后，需实现回调函数 connectionChangeActionCallback，以完成在某种网络切换状态下对推流连接的处理判断。
*/
@property (nonatomic, assign, getter=isMonitorNetworkStateEnable) BOOL monitorNetworkStateEnable;

/*!
 @abstract   自动断线重连开关，默认关闭。

 @discussion 该方法在推流 SDK 内部实现断线自动重连。若开启此机制，则当推流因异常导致中断时，-mediaStreamingSession:didDisconnectWithError:回调不会马上被触发，推流将进行最多三次自动重连，每次重连的等待时间会由初次的 0~2s 递增至最大 10s。等待重连期间，推流状态 streamState 会变为 PLStreamStateAutoReconnecting。一旦三次自动重连仍无法成功连接，则放弃治疗，-mediaStreamingSession:didDisconnectWithError:回调将被触发。
 该机制默认关闭，用户可在 -mediaStreamingSession:didDisconnectWithError: 方法中自定义添加断线重连处理逻辑。

 @see connectionInterruptionHandler
 */
@property (nonatomic, assign, getter=isAutoReconnectEnable) BOOL autoReconnectEnable;

/*!
 @abstract   开启自适应码率调节功能

 @param      minVideoBitRate 最小平均码率

 @discussion 该方法在推流 SDK 内部实现动态码率调节。开启该机制时，需设置允许调节的最低码率，以便使自动调整后的码率不会低于该范围。该机制根据网络吞吐量来调节推流的码率，在网络带宽变小导致发送缓冲区数据持续增长时，SDK 内部将适当降低推流码率，若情况得不到改善，则会重复该过程直至平均码率降至用户设置的最低值；反之，当一段时间内网络带宽充裕，SDK 将适当增加推流码率，直至达到预设的推流码率。
 自适应码率机制默认关闭，用户可利用 -mediaStreamingSession:streamStatusDidUpdate 回调数据实现自定义版本的码率调节功能。
 */
- (void)enableAdaptiveBitrateControlWithMinVideoBitRate:(NSUInteger)minVideoBitRate;

/*!
 @abstract 关闭自适应码率调节功能，默认即为关闭状态
 */
- (void)disableAdaptiveBitrateControl;

/*!
 @abstract   推流断开用户回调

 @discussion 该回调函数传入参数为推流断开产生的错误信息 error。返回值为布尔值，YES 表示在该错误状态下允许推流自动重连，NO 则代表不允许自动重连。本回调函数与 autoReconnectEnable 开关配合作用，只有在该开关开启时，本回调会在自动重连之前被调用，并通过返回值判断是否继续自动重连。若用户未设置该回调方法，则按默认策略最多进行三次自动重连。

 @warning    该回调会在主线程中执行

 @see        autoReconnectEnable
 */
@property (nonatomic, copy) ConnectionInterruptionHandler connectionInterruptionHandler;

/*!
 @abstract   网络切换用户回调

 @discussion 该回调函数与 monitorNetworkStateEnable 开关配合作用，只有将该开关开启时，该回调才会执行。该回调函数传入参数为当前网络的切换状态 PLNetworkStateTransition。返回值为布尔值，YES 表示在某种切换状态下允许推流自动重启，NO 则代表该状态下不应自动重启。该回调与自动重连回调 connectionInterruptionHandler 的区别在于，当推流网络从 WWAN 切换到 WiFi 时，推流不会被断开而继续使用 WWAN，此时自动重连机制不会被触发，SDK 内部会调用 connectionChangeActionCallback 来判断是否需要重启推流以使用优先级更高的网络。值得注意的是，在开启自动重连开关 autoReconnectEnable，并实现了本回调的情况下，推流时网络从 WiFi 切换到 WWAN，SDK 将优先执行本回调函数判断是否主动重启推流。如果用户选择在此情况下不主动重启，则等推流连接超时后将自动重连决定权交予 connectionInterruptionHandler 判断。如果两个回调均未被实现，则该情况下会默认断开推流以防止用户流量消耗。

 @warning    该回调会在主线程中执行

 @see        monitorNetworkStateEnable
 @see        connectionInterruptionHandler
 */
@property (nonatomic, copy) ConnectionChangeActionCallback connectionChangeActionCallback;

/*!
 @abstract   使用 QUIC 协议推流，默认处于关闭状态

 @discussion 打开该开关后，将使用 QUIC 协议推流，弱网下有更好的效果。

 @warning   请在开始推流前设置，推流过程中设置该值不会影响当次推流的行为。
 @warning   使用 QUIC 协议推流到不支持 QUIC 的 CDN 会失败。

 @since      v2.3.0
 */
@property (nonatomic, assign, getter=isQuicEnable) BOOL quicEnable;

/*!
 @abstract   使用 stream 对象指定推流地址时请使用该方法开始推流。

 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。

 @discussion 当 Streaming Session 创建并初始化好后（务必确认 stream 对象已设置好），就可以调用此方法开始推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。

 @warning    当采用 dynamic 认证且过期时，需要更新 Stream 对象，否则推流将失败。

 @see        stop
 @see        destroy

 @since      v2.0.0
 */
- (void)startStreamingWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @abstract   使用 streamURL 的方式指定推流地址时请使用该方法开始推流。

 @param      pushURL 推流地址，地址格式一般以 `rtmp://` 开头。
 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。

 @discussion 当 Streaming Session 创建并初始化好后就可以调用此方法开始推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。

 @see        stop
 @see        destroy

 @since      v2.0.0
 */
- (void)startStreamingWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @abstract   使用 stream 对象指定推流地址时请使用该方法重新开始推流。

 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。

 @discussion 当 Streaming Session 处于正在推流过程中，由于业务原因（如用户网络从 4G 切到 WIFI）需要快速重新推流时，可以调用此方法重新推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。
 *
 @warning    当前 Streaming Session 处于正在推流状态时调用此方法时才会重新推流，其它状态时调用无效
 Streaming Session。
             当采用 dynamic 认证且过期时，需要更新 Stream 对象，否则推流将失败。

 @see        stop
 @see        destroy
 *
 @since      v2.0.0
 */
- (void)restartStreamingWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @abstract   使用 streamURL 的方式指定推流地址时请使用该方法重新开始推流。

 @param      pushURL 需要重新推流的推流地址
 @param      handler 流连接的结果会通过该回调方法返回，携带连接状态的枚举，当 feedback 为 PLStreamStartStateSuccess 时表示连接成功，其他状态均为连接失败。

 @discussion 当 Streaming Session 处于正在推流过程中，由于业务原因（如用户网络从 4G 切到 WIFI）需要快速重新推流时，可以调用此方法重新推流。当要停止一次推流但是并不销毁 Streaming Session
 对象时，调用 -stop 方法即可，便于在需要重新推流时再重新调用该方法进行推流。如果确认不再使用对应 stream 进行推流，可以调用 -destroy 销毁
 Streaming Session 对象，销毁后的对象不可再用于推流或做其他操作，如有需求，需要创建一个新的 Streaming Session 对象。<br>
 handler 回调的线程会优先使用 delegateQueue, 如果 delegateQueue 未设置，会在主线程异步调用。

 @warning    当前 Streaming Session 处于正在推流状态时调用此方法时才会重新推流，其它状态时调用无效
 Streaming Session。

 @see        stop
 @see        destroy

 @since      v2.0.0
 */
- (void)restartStreamingWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;

/*!
 @abstract 结束推流
 */
- (void)stopStreaming;

/*!
 @abstract 重新加载视频推流配置

 @param videoStreamingConfiguration 新的视频编码配置
 */
- (void)reloadVideoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration;

/*!
 @abstract   人工报障

 @discussion 在出现特别卡顿的时候，可以调用此方法，上报故障。
 */
- (void)postDiagnosisWithCompletionHandler:(nullable PLStreamDiagnosisResultHandler)handle;

/*!
 @abstract   发送 SEI 消息

 @discussion 视频编码数据中规定的一种附加增强信息，平时一般不被使用，可以在其中加入一些自定义消息，这些消息会被直播 CDN 转发到观众端。

 @warning    由于消息是直接被塞入视频数据中的，所以不能太大（几个字节比较合适）

 @since      v2.3.5
 */
- (void)pushSEIMessage:(nonnull NSString *)message repeat:(NSInteger)repeatNum;

@end

#pragma mark - Category (CameraSource)

/*!
 @category   PLMediaStreamingSession(CameraSource)

 @discussion 与摄像头相关的接口
 */
@interface PLMediaStreamingSession (CameraSource)

/*!
 @abstract 视频采集 session

 @warning 只读属性，给有特殊需求的开发者使用，最好不要修改。

 @since    v2.3.2
 */
@property (nonatomic, readonly) AVCaptureSession * _Nullable captureSession;

/*!
 @abstract 视频采集输入源

 @warning 只读属性，给有特殊需求的开发者使用，最好不要修改。

 @since    v2.3.2
 */
@property (nonatomic, readonly) AVCaptureDeviceInput * _Nullable videoCaptureDeviceInput;

/*!
 @abstract   开启 camera 时，摄像头采集的位置

 @discussion 默认是后置摄像头 AVCaptureDevicePositionBack。
 */
@property (nonatomic, assign) AVCaptureDevicePosition   captureDevicePosition;

/*!
 @abstract   开启 camera 时，采集摄像头的旋转方向

 @discussion 默认为 AVCaptureVideoOrientationPortrait
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/*!
 @abstract 手电筒开关，默认为 NO 不开启。
 */
@property (nonatomic, assign, getter=isTorchOn) BOOL    torchOn;

/*!
 @abstract 连续自动对焦，默认为 YES 开启。
 */
@property (nonatomic, assign, getter=isContinuousAutofocusEnable) BOOL  continuousAutofocusEnable;

/*!
 @abstract   手动点击屏幕进行对焦，默认为 YES 开启。
 */
@property (nonatomic, assign, getter=isTouchToFocusEnable) BOOL touchToFocusEnable;

/*!
 @abstract   自动平滑聚焦
 *
 @discussion 默认为 YES 开启，适用于视频拍摄过程中用来减缓因自动对焦产生的镜头伸缩，使画面不因快速的对焦而产生抖动感。
 */
@property (nonatomic, assign, getter=isSmoothAutoFocusEnabled) BOOL  smoothAutoFocusEnabled;

/*!
 @abstract   聚焦点位置
 *
 @discussion 默认值为 (0.5, 0.5), (0,0) 是 top-left, (1,1) 是 bottom-right。
 */
@property (nonatomic, assign) CGPoint focusPointOfInterest;

/*!
 @abstract   视频画面伸缩
 *
 @discussion 默认为 1.0，设置的数值需要小于等于 videoActiveForat.videoMaxZoomFactor，如果大于会设置失败。
 */
@property (nonatomic, assign) CGFloat videoZoomFactor;

/*!
 @abstract   摄像头设备信息描述数组，只读属性。
 */
@property (nonatomic, strong, readonly) NSArray<AVCaptureDeviceFormat *> *videoFormats;

/*!
 @abstract 摄像头设备信息描述
 */
@property (nonatomic, strong) AVCaptureDeviceFormat *videoActiveFormat;

/*!
 @abstract   采集的视频的 sessionPreset，默认为 AVCaptureSessionPreset640x480
 */
@property (nonatomic, copy) NSString *sessionPreset;

/*!
 @abstract   采集的视频数据的帧率，默认为 30fps。
 */
@property (nonatomic, assign) NSUInteger videoFrameRate;

/*!
 @abstract   前置预览是否开启镜像，默认为 YES 开启。
 */
@property (nonatomic, assign) BOOL previewMirrorFrontFacing;

/*!
 @abstract   后置预览是否开启镜像，默认为 NO 关闭。
 */
@property (nonatomic, assign) BOOL previewMirrorRearFacing;

/*!
 @abstract   前置摄像头，推的流是否开启镜像，默认 NO 关闭。
 */
@property (nonatomic, assign) BOOL streamMirrorFrontFacing;

/*!
 @abstract   后置摄像头，推的流是否开启镜像，默认 NO 关闭。
 */
@property (nonatomic, assign) BOOL streamMirrorRearFacing;

/*!
 @abstract 推流预览的渲染队列
 */
@property (nonatomic, strong, readonly) dispatch_queue_t renderQueue;

/*!
 @abstract 推流预览的渲染 OpenGL context
 */
@property (nonatomic, strong, readonly) EAGLContext *renderContext;

/*!
 @abstract 转换前后置摄像头
*/
- (void)toggleCamera;

/*!
 @abstract   开启摄像头 session

 @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，在调用过 - (void)stopCaptureSession 方法后，
 如果要重新启用推流的摄像头，可以调用这个方法

 @see - (void)stopCaptureSession
 */
- (void)startCaptureSession;

/*!
 @abstract   停止摄像头 session

 @discussion 这个方法一般不需要调用，但当你的 App 中需要同时使用到 AVCaptureSession 时，当你需要暂且切换到你自己定制的摄像头做别的操作时，
 你需要调用这个方法来暂停当前 streaming session 对 captureSession 的占用。当需要恢复时，调用 - (void)startCaptureSession 方法。

 @see - (void)startCaptureSession
 */
- (void)stopCaptureSession;

/*!
 @warning 由于硬件性能限制，为了保证推流的质量，下列 API 只支持 iPhone 5、iPad 3、iPod touch 4 及以上的设备，在低端设备上将无效。
 */

/*!
 @abstract 是否开启美颜

 @param beautifyModeOn BOOL 值，决定开启或关闭美颜

 @warning  当 beautifyModeOn 为 NO 时，beautify、whiten 以及 redden 的值，无论是否不为 0，都将无效。

 @see -(void)setBeautify:(CGFloat)beautify;
 @see -(void)setWhiten:(CGFloat)whiten;
 @see -(void)setRedden:(CGFloat)redden;
 */
-(void)setBeautifyModeOn:(BOOL)beautifyModeOn;

/*!
 @abstract 设置对应 Beauty 的程度参数

 @param beautify 范围从 0 ~ 1，0 为不美颜

 @warning  如果美颜 beautifyModeOn 不开启，设置美白程度参数无效

 @see -(void)setBeautifyModeOn:(BOOL)beautifyModeOn;
 */
-(void)setBeautify:(CGFloat)beautify;

/*!
 @abstract 设置美白程度

 @param whiten 范围是从 0 ~ 1，0 为不美白

 @warning  如果美颜 beautifyModeOn 不开启，设置美白程度参数无效

 @see -(void)setBeautifyModeOn:(BOOL)beautifyModeOn;
 */
-(void)setWhiten:(CGFloat)whiten;

/*!
 @abstract 设置红润的程度参数

 @param redden 范围是从 0 ~ 1，0 为不红润

 @warning  如果美颜 beautifyModeOn 不开启，设置红润程度参数无效

 @see -(void)setBeautifyModeOn:(BOOL)beautifyModeOn;
 */

-(void)setRedden:(CGFloat)redden;

/*!
 @abstract 开启水印

 @param wateMarkImage 水印的图片
 @param position      水印的位置
 */
-(void)setWaterMarkWithImage:(UIImage *)wateMarkImage position:(CGPoint)position;

/*!
 @abstract 移除水印
 */
-(void)clearWaterMark;

/*!
 @abstract 视频截图

 @param handler 类型为 PLStreamScreenshotHandler 的 block

 @discussion 截图操作为异步，完成后将通过 handler 回调返回 UIImage 类型图片数据，
             请在Handler里自行指定您所需要操作 UIImage 的队列。

 @since      v2.2.0
 */
- (void)getScreenshotWithCompletionHandler:(nullable PLStreamScreenshotHandler)handler;

/*!
 @abstract 设置推流图片

 @param image 推流的图片

 @discussion 由于某些特殊原因不想使用摄像头采集的数据来推流时，可以使用该接口设置一张图片来替代。传入 nil 则关闭该功能。

 @warning    请确保传入的 image 的宽和高是 16 的整数倍。请勿在 applicationState 为 UIApplicationStateBackground 时调用该接口，否则将出错。

 @since      v2.2.1
 */
- (void)setPushImage:(nullable UIImage *)image;

@end

#pragma mark - Category (OverlayView)

/*!
 @category   PLMediaStreamingSession(OverlayView)

 @discussion 与贴纸、文字相关的接口
 */
@interface PLMediaStreamingSession (OverlayView)

/*!
 @abstract 贴纸、文字的父视图

 @since    v2.3.2
 */
@property (nonatomic, strong, readonly) UIView * _Nonnull overlaySuperView;

/*!
 @abstract 将 view 添加到 overlaySuperView 上

 @param view 要添加的视图

 @since v2.3.2
 */
- (void)addOverlayView:(UIView * _Nullable )view;

/*!
 @abstract 刷新 overlaySuperView 上的 view 视图

 @param view 要刷新的视图

 @since v2.3.2
 */
- (void)refreshOverlayView:(UIView * _Nullable)view;

/*!
 @abstract 将 view 从 overlaySuperView 上移除

 @param view 要移除的视图
 
 @since v2.3.2
 */
- (void)removeOverlayView:(UIView * _Nullable)view;

/*!
 @abstract 将 overlaySuperView 上的所有子视图 view 移除

 @since    v2.3.2
 */
- (void)removeAllOverlayViews;

@end

#pragma mark - Category (MicrophoneSource)

/*!
 @category   PLMediaStreamingSession(MicrophoneSource)

 @discussion 与麦克风相关的接口
 */
@interface PLMediaStreamingSession (MicrophoneSource)

/*!
 @abstract 返听功能，默认为 NO 关闭。
 */
@property (nonatomic, assign, getter=isPlayback) BOOL playback;

/*!
 @abstract 静音功能，默认为 NO 关闭。
 */
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/*!
 @abstract 是否允许在后台与其他 App 的音频混音而不被打断，默认为 NO 关闭。
 */
@property (nonatomic, assign) BOOL allowAudioMixWithOthers;

/*!
 @abstract 音频被其他 app 中断开始时会回调的函数
 
 @warning  回调不在主线程进行。
 */
@property (nonatomic, copy) PLAudioSessionDidBeginInterruptionCallback _Nullable audioSessionBeginInterruptionCallback;

/*!
 @abstract 结束音频被其他 app 中断时会回调的函数

 @warning  回调不在主线程进行。
 */
@property (nonatomic, copy) PLAudioSessionDidEndInterruptionCallback _Nullable audioSessionEndInterruptionCallback;

/*!
 @abstract    麦克风采集的音量

 @discussion  设置范围为 0~1，各种机型默认值不同。iPhone 6s 系列不支持调节麦克风采集的音量。
 */
@property (nonatomic, assign) float inputGain;

/*!
 @abstract 所有生效音效的数组

 @see PLAudioEffectConfiguration
 */
@property (nonatomic, strong) NSArray<PLAudioEffectConfiguration *> *audioEffectConfigurations;

/*!
 @abstract   绑定一个音频文件播放器

 @param audioFilePath 音频文件路径

 @discussion 该播放器播放出的声音将和麦克风声音混和，并推流出去。

 @see PLAudioPlayer
 */
- (PLAudioPlayer *)audioPlayerWithFilePath:(NSString *)audioFilePath;

/*!
 @abstract 关闭当前的音频文件播放器
 */
- (void)closeCurrentAudio;

@end

#pragma mark - Categroy (Application)

/*!
 @category   PLMediaStreamingSession(Application)

 @discussion 与系统相关的接口
 */
@interface PLMediaStreamingSession (Application)

/*!
 @abstract 系统锁屏功能

 @discussion 默认为 NO 关闭
 */
@property (nonatomic, assign, getter=isIdleTimerDisable) BOOL idleTimerDisable;

@end

#pragma mark - Category (Authorization)

/*!
 @category   PLMediaStreamingSession(Authorization)

 @discussion 与设备授权相关的接口
 */
@interface PLMediaStreamingSession (Authorization)

/*!
 @abstract camera 权限状态
 */
+ (PLAuthorizationStatus)cameraAuthorizationStatus;

/*!
 @abstract 获取摄像头权限
 
 @param handler 该 block 将会在主线程中回调。
 */
+ (void)requestCameraAccessWithCompletionHandler:(void (^)(BOOL granted))handler;

/*!
 @abstract Microphone 权限状态
 */
+ (PLAuthorizationStatus)microphoneAuthorizationStatus;

/*!
 @abstract 获取麦克风权限
 
 @param handler 该 block 将会在主线程中回调。
 */
+ (void)requestMicrophoneAccessWithCompletionHandler:(void (^)(BOOL granted))handler;
@end

#pragma mark - Category (Info)

/*!
 @category   PLMediaStreamingSession(Info)

 @discussion sdk 相关信息
 */
@interface PLMediaStreamingSession (Info)

/*!
 @abstract PLCameraStreamingKit 的 SDK 版本。

 @since    v1.8.1
 */
+ (NSString *)versionInfo;

/*!
 @abstract SDK 授权状态查询

 @param resultBlock 授权状态查询完成之后的回调

 @since    v3.0.0
 */
+ (void)checkAuthentication:(void(^ __nonnull)(PLAuthenticationResult result))resultBlock;

@end

NS_ASSUME_NONNULL_END
