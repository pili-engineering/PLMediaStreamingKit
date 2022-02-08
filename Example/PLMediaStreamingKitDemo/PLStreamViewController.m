//
//  PLStreamViewController.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/8.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "PLStreamViewController.h"
#import "PLButtonControlsView.h"
#import "PLShowDetailView.h"
#import "PLInputTextView.h"
#import "PLAssetReader.h"

// 系统录屏 ReplayKit
#import <ReplayKit/ReplayKit.h>

// 流状态 String
static NSString *StreamState[] = {
    @"PLStreamStateUnknow",
    @"PLStreamStateConnecting",
    @"PLStreamStateConnected",
    @"PLStreamStateDisconnecting",
    @"PLStreamStateDisconnected",
    @"PLStreamStateAutoReconnecting",
    @"PLStreamStateError"
};

// bundleId 授权状态 String
static NSString *AuthorizationStatus[] = {
    @"PLAuthorizationStatusNotDetermined",
    @"PLAuthorizationStatusRestricted",
    @"PLAuthorizationStatusDenied",
    @"PLAuthorizationStatusAuthorized"
};

// 音频混音文件错误 String
static NSString *AudioFileError[] = {
    @"PLAudioPlayerFileError_FileNotExist",
    @"PLAudioPlayerFileError_FileOpenFail",
    @"PLAudioPlayerFileError_FileReadingFail"
};

// PreferredExtension
static NSString *PLPreferredExtension = @"com.qbox.PLMediaStreamingKitDemo.PLReplaykitExtension";

@interface PLStreamViewController ()
<
// PLMediaStreamingSession 的代理
PLMediaStreamingSessionDelegate,
// PLAudioPlayer 的代理
PLAudioPlayerDelegate,
// PLStreamingSession 的代理
PLStreamingSessionDelegate,

// 系统 RPBroadcast
RPBroadcastActivityViewControllerDelegate,
RPBroadcastControllerDelegate,
// RPScreenRecorder
RPScreenRecorderDelegate,

// 自定义 view 的代理
PLButtonControlsViewDelegate,
PLShowDetailViewDelegate,
PLInputTextViewDelegate
>

#warning PLMediamediaSession 音视频采集 推流核心类
@property (nonatomic, strong) PLMediaStreamingSession *mediaSession;
#warning PLStreamingSession 外部导入音视频 推流核心类
@property (nonatomic, strong) PLStreamingSession *streamSession;

// 推流混音播放器
@property (nonatomic, strong) PLAudioPlayer *audioPlayer;

// UI
@property (nonatomic, strong) PLButtonControlsView *buttonControlsView;
@property (nonatomic, strong) UILabel *streamLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) PLShowDetailView *detailView;
@property (nonatomic, strong) UIImageView *pushImageView;
@property (nonatomic, strong) UIImageView *watermarkImageView;
@property (nonatomic, assign) CGPoint watermarkPoint;
@property (nonatomic, strong) UISlider *zoomSlider;
// 录制全屏时，不显示
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *seiButton;
@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, assign) CGFloat topSpace;

// 外部导入数据
@property (nonatomic, strong) PLAssetReader *assetReader;
@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) CGFloat frameRate;
// 音视频解码时间戳同步
@property (nonatomic, assign) CFAbsoluteTime startActualFrameTime;

// 计时
@property (nonatomic, strong) UILabel *timingLabel;
@property (nonatomic, strong) NSTimer *timer;

// 录屏
@property (nonatomic, strong) RPBroadcastActivityViewController *broadcastActivityVC API_AVAILABLE(ios(10.0));
@property (nonatomic, strong) RPBroadcastController *broadcastController API_AVAILABLE(ios(10.0));
@property (nonatomic, strong) RPSystemBroadcastPickerView *broadcastPickerView API_AVAILABLE(ios(12.0));
@property (nonatomic, strong) RPScreenRecorder *screenRecorder;
@property (nonatomic, assign) BOOL needRecordSystem;

@property (nonatomic, strong) NSString *systemVersion;

@end

@implementation PLStreamViewController

- (void)dealloc {
    // 必须移除监听
    [self removeObservers];
    
    [_mediaSession removeAllOverlayViews];
    [_mediaSession closeCurrentAudio];
    
    // 销毁 PLMediaStreamingSession
    if (_mediaSession.isStreamingRunning) {
        [_mediaSession stopStreaming];
        _mediaSession.delegate = nil;
        _mediaSession = nil;
    }
    
    // 销毁 PLStreamingSession
    if (_streamSession.isRunning) {
        [_streamSession stop];
        _streamSession.delegate = nil;
        _streamSession = nil;
    }
    // 打印代表 PLStreamViewController 成功释放
    NSLog(@"[PLStreamViewController] dealloc !");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_streamSession && _mSettings.streamType == 3) {
        // 弹框选择录屏类型
        [self selectedReplayType];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止导入
    if (_mSettings.streamType == 2) {
        [self stopPushBuffer];
    }
    
    if (_mSettings.streamType == 3) {
        // 销毁计时器，防止内存泄漏
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        
        // 停止录屏
        [self stopReplayLive];
        [self stopScreenRecorder];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupStreamSession];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // UI 适配顶部
    CGFloat space = 24;
    if (PL_iPhoneX || PL_iPhoneXR || PL_iPhoneXSMAX ||
        PL_iPhone12Min || PL_iPhone12Pro || PL_iPhone12PMax) {
        space = 44;
    }
    _topSpace = space + 4;
        
    // 音视频采集推流
    if (_mediaSession && _mSettings.streamType == 0) {
        [self configurateAVMediaStreamingSession];
        [self layoutButtonViewInterface];
        
    // 纯音频采集推流
    } else if (_mediaSession && _mSettings.streamType == 1) {
        // 遵守代理 PLMediaStreamingSessionDelegate
        _mediaSession.delegate = self;

        // 纯音频 本地背景板
        UIImageView *backImageView = [[UIImageView alloc] init];
        backImageView.image = [UIImage imageNamed:@"pl_audio_only_bg"];
        [self.view addSubview:backImageView];
        
        [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self.view);
        }];
    // 外部数据导入推流
    } else if (_streamSession && _mSettings.streamType == 2) {
        // 遵守代理 PLStreamingSessionDelegate
        _streamSession.delegate = self;
        
        // AVAsset 解码，获取音视频数据
        [self initAssetReader];
        
        // 提示 label
        UILabel *tintLabel = [[UILabel alloc] init];
        tintLabel.center = self.view.center;
        tintLabel.font = FONT_MEDIUM(11);
        tintLabel.textColor = [UIColor blackColor];
        tintLabel.textAlignment = NSTextAlignmentCenter;
        tintLabel.text = @"将直接使用选择的视频进行推流，请至拉流端观看！";
        [self.view addSubview:tintLabel];
        
        [tintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.view);
            make.width.mas_equalTo(self.view.mas_width);
            make.height.mas_equalTo(26);
        }];
    // 录屏推流
    } else if (_streamSession && _mSettings.streamType == 3) {
        // 遵守代理 PLStreamingSessionDelegate
        _streamSession.delegate = self;
        
        // RPScreenRecorder 设置
        _screenRecorder = [RPScreenRecorder sharedRecorder];
        _screenRecorder.delegate = self;
        _screenRecorder.microphoneEnabled = YES;
        
        _systemVersion = [[UIDevice currentDevice] systemVersion];
        // 计时时间显示
        _timingLabel = [[UILabel alloc] init];
        _timingLabel.numberOfLines = 0;
        _timingLabel.center = self.view.center;
        _timingLabel.font = FONT_MEDIUM(12);
        _timingLabel.textColor = [UIColor blackColor];
        _timingLabel.textAlignment = NSTextAlignmentCenter;
        _timingLabel.text = [NSString stringWithFormat:@"系统 iOS %@\n当前时间: %@", _systemVersion, [self getCurrentTime]];
        [self.view addSubview:_timingLabel];

        [_timingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.view);
            make.width.mas_equalTo(self.view.mas_width);
            make.height.mas_equalTo(56);
        }];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timingAction:) userInfo:nil repeats:YES];
    }
    
    // 布局 button 控件视图
    [self layoutCommonView];
    
    // 添加退前后台监听处理
    [self addObservers];
}

-(void)setupStreamSession{
    //默认配置
    PLVideoCaptureConfiguration *videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
    PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    PLVideoStreamingConfiguration *videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
    PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    
    //使用设置项
    videoCaptureConfiguration = _mSettings.videoSettings.videoCaptureConfiguration;
    audioCaptureConfiguration = _mSettings.audioSettings.audioCaptureConfiguration;
    videoStreamingConfiguration  = _mSettings.videoStreamConfiguration;
    audioStreamingConfiguration = _mSettings.audioStreamingConfiguration;
    switch (_mSettings.streamType) {
            case PLStreamTypeAll:
                _mediaSession = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
                break;
            case PLStreamTypeAudioOnly:
                _mediaSession = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:nil audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:nil audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
                break;
            case PLStreamTypeImport:
                _streamSession = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
                break;
            case PLStreamTypeScreen:
                _streamSession = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
                break;

            default:
                break;
        }
    
    if (_mSettings.streamType == PLStreamTypeAll || _mSettings.streamType == PLStreamTypeAudioOnly) {
        [self resetMediaSessionSettings];
    }else{
        [self resetStreamSessionSettings];
    }
    
    
}

-(void)resetMediaSessionSettings{
    // 协议类型
    _mediaSession.protocolModel = _mSettings.protocolModel;
    // 画面填充模式
    _mediaSession.fillMode = _mSettings.fillMode;
    // QUIC 协议
    _mediaSession.quicEnable = _mSettings.quicEnable;
    // 自适应码率
    _mediaSession.dynamicFrameEnable = _mSettings.dynamicFrameEnable;
    // 开启自适应码率调节功能 最小平均码率
    if (0 == _mSettings.minVideoBitRate) {
        [_mediaSession disableAdaptiveBitrateControl];
    }else{
        [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:_mSettings.minVideoBitRate];
    }
    // 自动重连
    _mediaSession.autoReconnectEnable = _mSettings.autoReconnectEnable;
    // 开启网络切换监测
    _mediaSession.monitorNetworkStateEnable = _mSettings.monitorNetworkStateEnable;
    // 回调方法的调用间隔
    _mediaSession.statusUpdateInterval = _mSettings.statusUpdateInterval;
    // 流信息更新间隔
    _mediaSession.threshold = _mSettings.threshold;
    // 发送队列最大容纳包数量。
    _mediaSession.maxCount = _mSettings.maxCount;
    // 控制系统屏幕自动锁屏是否关闭。
    _mediaSession.idleTimerDisable = _mSettings.idleTimerDisable;
    
    _mediaSession.continuousAutofocusEnable = _mSettings.videoSettings.continuousAutofocusEnable;
    _mediaSession.touchToFocusEnable = _mSettings.videoSettings.touchToFocusEnable;
    _mediaSession.smoothAutoFocusEnabled = _mSettings.videoSettings.smoothAutoFocusEnabled;
    _mediaSession.torchOn = _mSettings.videoSettings.torchOn;

    _mediaSession.playback = _mSettings.audioSettings.playback;
    _mediaSession.inputGain = _mSettings.audioSettings.inputGain;
    _mediaSession.allowAudioMixWithOthers = _mSettings.audioSettings.allowAudioMixWithOthers;

}

-(void)resetStreamSessionSettings{
    // 协议类型
    _streamSession.protocolModel = _mSettings.protocolModel;
    // QUIC 协议
    _streamSession.quicEnable = _mSettings.quicEnable;
    // 自适应码率
    _streamSession.dynamicFrameEnable = _mSettings.dynamicFrameEnable;
    // 开启自适应码率调节功能 最小平均码率
    if (0 == _mSettings.minVideoBitRate) {
        [_streamSession disableAdaptiveBitrateControl];
    }else{
        [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:_mSettings.minVideoBitRate];
    }
    // 自动重连
    _streamSession.autoReconnectEnable = _mSettings.autoReconnectEnable;
    // 开启网络切换监测
    _streamSession.monitorNetworkStateEnable = _mSettings.monitorNetworkStateEnable;
    // 回调方法的调用间隔
    _streamSession.statusUpdateInterval = _mSettings.statusUpdateInterval;
    // 流信息更新间隔
    _streamSession.threshold = _mSettings.threshold;
    // 发送队列最大容纳包数量。
    _streamSession.maxCount = _mSettings.maxCount;
    // 控制系统屏幕自动锁屏是否关闭。
    _streamSession.idleTimerDisable = _mSettings.idleTimerDisable;
    
}


#pragma mark - 音视频采集推流
- (void)configurateAVMediaStreamingSession {
    // 添加预览视图到父视图
    [self.view insertSubview:_mediaSession.previewView atIndex:0];
    
    // 配置采集预览视图 frame
    [_mediaSession.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets = UIEdgeInsetsZero;
    }];
    
    // 遵守代理 PLMediaStreamingSessionDelegate
    _mediaSession.delegate = self;
    
    // 美颜配置开启，且参数均为 0.5
    [_mediaSession setBeautifyModeOn:YES];
    [_mediaSession setBeautify:0.5];
    [_mediaSession setWhiten:0.5];
    [_mediaSession setRedden:0.5];
    
    // 麦克风权限
    [PLMediaStreamingSession requestMicrophoneAccessWithCompletionHandler:^(BOOL granted) {
        PLAuthorizationStatus status = [PLMediaStreamingSession microphoneAuthorizationStatus];
        if (granted) {
            if (status == PLAuthorizationStatusAuthorized) {
                // 混音配置
                // 首次加载，在成功获取麦克风权限后，传递配置音乐文件才能成功
                _audioPlayer = [_mediaSession audioPlayerWithFilePath:[[NSBundle mainBundle] pathForResource:@"TestMusic1" ofType:@"m4a"]];
                _audioPlayer.delegate = self;
                _audioPlayer.volume = 0.5;
            }
        } else{
            [self presentViewAlert:@"麦克风权限异常！"];
        }
    }];
}

#pragma mark - PLMediaStreamingSessionDelegate
// 推流时流状态变更的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        _streamLabel.text = StreamState[state];
        NSLog(@"[PLStreamViewController] 流状态: %@", StreamState[state]);
    });
}

// 推流失去连接发生错误的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[PLStreamViewController] 失去连接发生错误: error %@, code %ld", error.localizedDescription, error.code);
    });
}

// 推流中流数据信息的更新回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.statusLabel.text = [NSString stringWithFormat:@"video %.1f fps\naudio %.1f fps\nvideo %.1f bps\naudio %.1f bps\ntotal bitrate %.1f kbps",status.videoFPS, status.audioFPS, status.videoBitrate, status.audioBitrate, status.totalBitrate/1000];
        NSLog(@"[PLStreamViewController] PLStreamStatus 的信息: video FPS %.1f, audio FPS %.1f, video Bps %.1f, audio Bps %.1f, total bitrate %.1f", status.videoFPS, status.audioFPS, status.videoBitrate, status.audioBitrate, status.totalBitrate);
    });
}

// 提前获取摄像头和麦克风的使用授权，避免出现 session 部分配置未生效的问题
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didGetCameraAuthorizationStatus:(PLAuthorizationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[PLStreamViewController] 摄像头授权状态: %@", AuthorizationStatus[status]);
    });
}
// 提前获取摄像头和麦克风的使用授权，避免出现 session 部分配置未生效的问题
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didGetMicrophoneAuthorizationStatus:(PLAuthorizationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[PLStreamViewController] 麦克风授权状态: %@", AuthorizationStatus[status]);
    });
}

// 摄像头采集的数据回调
- (CVPixelBufferRef)mediaStreamingSession:(PLMediaStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    /* 滤镜处理示例，仅供参考
    size_t w = CVPixelBufferGetWidth(pixelBuffer);
    size_t h = CVPixelBufferGetHeight(pixelBuffer);
    size_t par = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *pimg = CVPixelBufferGetBaseAddress(pixelBuffer);
    for (int i = 0; i < w; i ++){
        for (int j = 0; j < h; j++){
            pimg[j * par + i * 4 + 1] = 255;
        }
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
     */
    return pixelBuffer;
}

// 麦克风采集的数据回调
- (AudioBuffer *)mediaStreamingSession:(PLMediaStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer asbd:(nonnull const AudioStreamBasicDescription *)asbd {
//    [self printASBD:*asbd tag:@"test"];
    return audioBuffer;
}

- (void)printASBD:(AudioStreamBasicDescription)asbd tag:(NSString *)tag{
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';

    NSLog (@"%@  Sample Rate:  %10.0f", tag, asbd.mSampleRate);
    NSLog (@"%@  Format ID: %10s", tag, formatIDString);
    NSLog (@"%@  Format Flags: %10x", tag, asbd.mFormatFlags);
    NSLog (@"%@  Frames per Packet:   %10d", tag, asbd.mFramesPerPacket);
    NSLog (@"%@  Bytes per Frame:     %10d", tag, asbd.mBytesPerFrame);
    NSLog (@"%@  Channels per Frame:  %10d", tag, asbd.mChannelsPerFrame);
    NSLog (@"%@  Bits per Channel:    %10d", tag, asbd.mBitsPerChannel);
}


#pragma mark - PLAudioPlayerDelegate
// 音频播放发生错误的回调
- (void)audioPlayer:(PLAudioPlayer *)audioPlayer findFileError:(PLAudioPlayerFileError)fileError {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[PLStreamViewController] 音频文件发生错误: %@", AudioFileError[fileError]);
    });
}

// 音频播放进度的变化回调
- (void)audioPlayer:(PLAudioPlayer *)audioPlayer audioDidPlayedRateChanged:(double)audioDidPlayedRate {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.detailView.progressSlider.value = (float)audioDidPlayedRate;
    });
}

// 音频播放是否循环的回调
- (BOOL)didAudioFilePlayingFinishedAndShouldAudioPlayerPlayAgain:(PLAudioPlayer *)audioPlayer {
    // 以下 3 种场景可根据需求选择实现
    
    // 1）播放结束就停止
//    return NO;
    
    // 2）播放结束后，继续从头播放音频
    return YES;
    
    // 3）播放结束后，替换音频文件从头开始播放
//    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"TestMusic2" ofType:@"wav"];
//    audioPlayer.audioFilePath = audioPath;
//    return YES;
}

- (void)layoutCommonView {
    // 返回按钮
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(15, _topSpace, 65, 26)];
    backButton.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = FONT_MEDIUM(12.f);
    [backButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];

    // 流状态 label
    _streamLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _topSpace + 32, 150, 26)];
    _streamLabel.font = FONT_MEDIUM(11);
    _streamLabel.textColor = COLOR_RGB(181, 68, 68, 1);
    _streamLabel.textAlignment = NSTextAlignmentLeft;
    _streamLabel.text = @"";
    [self.view addSubview:_streamLabel];

    // 流信息 label
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _topSpace + 58, 150, 110)];
    _statusLabel.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    _statusLabel.font = FONT_LIGHT(11);
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentLeft;
    _statusLabel.numberOfLines = 0;
    _statusLabel.text = @" video 0.0 fps\n audio 0.0 fps\n video 0.0 bps\n audio 0.0 bps\n total bitrate 0.0kbps";
    [self.view addSubview:_statusLabel];
    
    // SEI 按钮
    _seiButton = [[UIButton alloc] initWithFrame:CGRectMake(15, _topSpace + 180, 65, 26)];
    _seiButton.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    [_seiButton setTitle:@"发送 SEI" forState:UIControlStateNormal];
    [_seiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _seiButton.titleLabel.font = FONT_MEDIUM(12.f);
    [_seiButton addTarget:self action:@selector(pushSEIData:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_seiButton];
    
    // 开始/停止推流按钮
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(15, _topSpace + 218, 65, 26)];
    _startButton.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    [_startButton setTitle:@"开始推流" forState:UIControlStateNormal];
    [_startButton setTitle:@"停止推流" forState:UIControlStateSelected];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startButton.titleLabel.font = FONT_MEDIUM(12.f);
    [_startButton addTarget:self action:@selector(startStream:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_startButton];
    
    
    _reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(15, _topSpace + 256, 65, 26)];
    _reloadButton.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    [_reloadButton setTitle:@"刷新 VFPS" forState:UIControlStateNormal];
    [_reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _reloadButton.titleLabel.font = FONT_MEDIUM(12.f);
    [_reloadButton addTarget:self action:@selector(reloadVideoFPS:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_reloadButton];
}

#pragma mark - UI 视图
- (void)layoutButtonViewInterface {
    // 摄像头转换按钮
    UIButton *cameraButton = [[UIButton alloc] init];
    [cameraButton setImage:[UIImage imageNamed:@"pl_switch_camera"] forState:UIControlStateNormal];
    cameraButton.titleLabel.font = FONT_MEDIUM(12.f);
    [cameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:cameraButton];
    
    // 按钮控件视图
    _buttonControlsView = [[PLButtonControlsView alloc] initWithFrame:CGRectZero show:NO];
    _buttonControlsView.delegate = self;
    [self.view addSubview:_buttonControlsView];
    
    // 细节设置 view
    _detailView = [[PLShowDetailView alloc] initWithFrame:CGRectZero backView:self.view];
    _detailView.delegate = self;
    [self.view addSubview:_detailView];
    
    // 图片推流 覆盖卡住的预览视图
    _pushImageView = [[UIImageView alloc] init];
    _pushImageView.userInteractionEnabled = YES;
    
    _watermarkImageView = [[UIImageView alloc] init];
    _watermarkImageView.userInteractionEnabled = YES;
    _watermarkPoint = CGPointZero;
    
    // 缩放的滑条
    CGFloat width = KSCREEN_WIDTH - 30;
    if (KSCREEN_HEIGHT < 667) {
        width = KSCREEN_WIDTH - 105;
    }
    _zoomSlider = [[UISlider alloc] init];
    _zoomSlider.value = 1.0;
    _zoomSlider.minimumValue = 1.0;
    // 获取相机实际的 videoMaxZoomFactor
    _zoomSlider.maximumValue = MIN(5, _mediaSession.videoActiveFormat.videoMaxZoomFactor);
    [_zoomSlider addTarget:self action:@selector(zoomVideo:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_zoomSlider];
    
    // masonry 集中布局
    [cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(_topSpace);
    }];
    
    [_buttonControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(65, 496));
        make.right.equalTo(self.view.mas_right).with.offset(-15);
        make.top.mas_equalTo(_topSpace);
    }];
    
    [_detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_bottom);
    }];
    
    [_zoomSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.equalTo(self.view).with.offset(18);
        make.right.equalTo(self.view).with.offset(-18);
        make.top.equalTo(self.view.mas_bottom).offset(-60);
    }];
}

#pragma mark - PLButtonControlsViewDelegate
- (void)buttonControlsView:(PLButtonControlsView *)buttonControlsView didClickIndex:(NSInteger)index selected:(BOOL)selected {
    if (index == 1) {
        // 预览镜像
        if (_mediaSession.captureDevicePosition == AVCaptureDevicePositionBack) {
            _mediaSession.previewMirrorRearFacing = selected;
        }
        if (_mediaSession.captureDevicePosition == AVCaptureDevicePositionFront) {
            _mediaSession.previewMirrorFrontFacing = selected;
        }
        
    } else if (index == 2) {
        // 编码镜像
        if (_mediaSession.captureDevicePosition == AVCaptureDevicePositionBack) {
            _mediaSession.streamMirrorRearFacing = selected;
        }
        if (_mediaSession.captureDevicePosition == AVCaptureDevicePositionFront) {
            _mediaSession.streamMirrorFrontFacing = selected;
        }

    } else if (index == 3) {
        // 打开/关闭 麦克风
        _mediaSession.muted = selected;
    } else if (index == 10) {
        // 截图
        [_mediaSession getScreenshotWithCompletionHandler:^(UIImage * _Nullable image) {
            if (image == nil) {
                return;
            }
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
    } else if (index == 11) {
        // 人工报障
        __weak typeof(self) weakSelf = self;
        [_mediaSession postDiagnosisWithCompletionHandler:^(NSString * _Nullable diagnosisResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentViewAlert:[NSString stringWithFormat:@"人工报障结果：%@！", diagnosisResult]];
                NSLog(@"[PLStreamViewController] diagnosisResult:%@", diagnosisResult);
            });
        }];
    } else {
        // 其他见 自定义视频 PLShowDetailViewDelegate 的回调处理
        NSInteger currentIndex;
        if (index == 0) {
            currentIndex = 0;
        } else{
            currentIndex = index - 3;
        }
        if (selected) {
            _zoomSlider.hidden = YES;
            [_detailView showDetailSettingViewWithType:currentIndex];
        } else{
            _zoomSlider.hidden = NO;
            [_detailView hideDetailSettingView];
        }
    }
}


#pragma mark - PLShowDetailViewDelegate
- (void)showDetailView:(PLShowDetailView *)showDetailView didClickIndex:(NSInteger)index currentType:(PLSetDetailViewType)type {
    // 转换方向
    if (type == PLSetDetailViewOrientaion) {
        [self adjustInterfaceAndDeviceIndex:index];
    }
    // 图片推流
    if (type == PLSetDetailViewImagePush) {
        NSArray *imageArray = @[@"", @"pushImage_720x1280", @"pushImage_leave"];
        NSString *imageStr = imageArray[index];
        
        if (imageStr.length != 0) {
            
            [_mediaSession.overlaySuperView removeFromSuperview];
            
            UIImage *image = [UIImage imageNamed:imageStr];
            [_mediaSession setPushImage:image];
            
            _pushImageView.image = image;
            [_pushImageView addSubview:_mediaSession.overlaySuperView];
            [_mediaSession.previewView addSubview:_pushImageView];
            [_pushImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.mas_equalTo(_mediaSession.previewView);
            }];
            
            if (_watermarkImageView.image) {
                _watermarkImageView.frame = CGRectMake(_watermarkPoint.x, _watermarkPoint.y, _watermarkImageView.image.size.width, _watermarkImageView.image.size.height);
                [_pushImageView addSubview:_watermarkImageView];
            }
        } else {
            [_mediaSession setPushImage:nil];
            if (_watermarkImageView.image) {
                [_watermarkImageView removeFromSuperview];
            }
            [_mediaSession.overlaySuperView removeFromSuperview];
            [_pushImageView removeFromSuperview];
            _pushImageView.image = nil;
            
            [_mediaSession.previewView addSubview:_mediaSession.overlaySuperView];
        }
    }
    // 水印
    if (type == PLSetDetailViewWaterMark) {
        NSArray *imageArray = @[@"", @"qiniu", @"xiaoqi1", @"xiaoqi2"];
        NSString *imageStr = imageArray[index];
        if (imageStr.length != 0) {
            UIImage *image = [UIImage imageNamed:imageStr];
            _watermarkImageView.image = image;
            CGPoint point = CGPointZero;
            // 根据实际分辨率，显示水印位置
            if ([_mediaSession.sessionPreset isEqualToString:AVCaptureSessionPreset352x288]) {
                point = CGPointMake(144 - image.size.width/2, 234 - image.size.height/3*2);
            }
            if ([_mediaSession.sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
                point = CGPointMake(240 - image.size.width/2, 426 - image.size.height/3*2);
            }
            if ([_mediaSession.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
                point = CGPointMake(360 - image.size.width/2, 894 - image.size.height/3*2);
            }
            if ([_mediaSession.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
                point = CGPointMake(540 - image.size.width/2, 1320 - image.size.height/3*2);
            }
            if ([_mediaSession.sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
                point = CGPointMake(1080 - image.size.width/2, 2560 - image.size.height/3*2);
            }
            _watermarkPoint = point;
            
            if (_pushImageView.image) {
                _watermarkImageView.frame = CGRectMake(_watermarkPoint.x, _watermarkPoint.y, _watermarkImageView.image.size.width, _watermarkImageView.image.size.height);
                [_pushImageView addSubview:_watermarkImageView];
            }
            [_mediaSession setWaterMarkWithImage:image position:point];
        } else {
            _watermarkImageView.image = nil;
            _watermarkPoint = CGPointZero;
            
            if (_watermarkImageView.image) {
                [_watermarkImageView removeFromSuperview];
            }
            [_mediaSession clearWaterMark];
        }
    }
    // 音效
    if (type == PLSetDetailViewAudioEffect) {
        switch (index) {
            case 0:
                _mediaSession.audioEffectConfigurations = nil;;
                break;
            case 1:
                _mediaSession.audioEffectConfigurations = @[[PLAudioEffectModeConfiguration reverbLowLevelModeConfiguration]];;
                break;
            case 2:
                _mediaSession.audioEffectConfigurations = @[[PLAudioEffectModeConfiguration reverbMediumLevelModeConfiguration]];;
                break;
            case 3:
                _mediaSession.audioEffectConfigurations = @[[PLAudioEffectModeConfiguration reverbHeightLevelModeConfiguration]];;
                break;

            default:
                break;
        }
    }
}

// 美颜调节
- (void)showDetailView:(PLShowDetailView *)showDetailView didChangeBeautyMode:(BOOL)beautyMode beauty:(CGFloat)beauty white:(CGFloat)white red:(CGFloat)red {
    [_mediaSession setBeautifyModeOn:beautyMode];
    [_mediaSession setBeautify:beauty];
    [_mediaSession setWhiten:white];
    [_mediaSession setRedden:red];
}

// 添加贴纸
- (void)showDetailView:(PLShowDetailView *)showDetailView didAddStickerView:(PLPasterView *)stickerView {
    CGFloat width = _mediaSession.videoStreamingConfiguration.videoSize.width;
    CGFloat height = _mediaSession.videoStreamingConfiguration.videoSize.height;
    _mediaSession.overlaySuperView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)/2 - height/width*CGRectGetWidth(self.view.frame)/2, CGRectGetWidth(self.view.frame), height/width*CGRectGetWidth(self.view.frame));
    [_mediaSession addOverlayView:stickerView];
}
// 移除贴纸
- (void)showDetailView:(PLShowDetailView *)showDetailView didRemoveStickerView:(PLPasterView *)stickerView {
    [_mediaSession removeOverlayView:stickerView];
}
// 刷新贴纸
- (void)showDetailView:(PLShowDetailView *)showDetailView didRefreshStickerView:(PLPasterView *)stickerView {
    [_mediaSession refreshOverlayView:stickerView];
}

// 混音播放状态 注意：开始推流了，才回正常播放
- (void)showDetailView:(PLShowDetailView *)showDetailView didUpdateAudioPlayer:(BOOL)play playBack:(BOOL)playBack file:(nonnull NSString *)file {
    if (![_audioPlayer.audioFilePath isEqualToString:file]) {
        if (_audioPlayer.isRunning) {
            [_audioPlayer pause];
        }
        _audioPlayer.audioFilePath = file;
    }
    _mediaSession.playback = playBack;
    if (play) {
        [_audioPlayer play];
    } else{
        [_audioPlayer pause];
    }
}
// 混音播放音量
- (void)showDetailView:(PLShowDetailView *)showDetailView didUpdateAudioPlayVolume:(CGFloat)volume {
    _audioPlayer.volume = volume;
}
// 混音播放进度
- (void)showDetailView:(PLShowDetailView *)showDetailView didUpdateAudioPlayProgress:(CGFloat)progress {
    _audioPlayer.audioDidPlayedRate = progress;
}

- (void)adjustInterfaceAndDeviceIndex:(NSInteger)index {
    // 摄像头采集方向数组
    NSArray *videoOrientationArray = @[@(AVCaptureVideoOrientationPortrait), @(AVCaptureVideoOrientationPortraitUpsideDown), @(AVCaptureVideoOrientationLandscapeRight), @(AVCaptureVideoOrientationLandscapeLeft)];
    NSArray *interfaceOrientationArray = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeRight), @(UIInterfaceOrientationLandscapeLeft)];
    NSInteger orientation = [videoOrientationArray[index] integerValue];

    CGFloat width = _mediaSession.videoStreamingConfiguration.videoSize.width;
    CGFloat height = _mediaSession.videoStreamingConfiguration.videoSize.height;
    CGSize videoSize = CGSizeZero;
    if (index == 2 || index == 3) {
        if (width > height) {
            videoSize = CGSizeMake(width, height);
        } else{
            videoSize = CGSizeMake(height, width);
        }
    } else{
        if (width > height) {
            videoSize = CGSizeMake(height, width);
        } else{
            videoSize = CGSizeMake(width, height);
        }
    }

    [[UIDevice currentDevice] setValue:interfaceOrientationArray[index] forKey:@"orientation"];
    _mediaSession.videoOrientation = orientation;

    if (!CGSizeEqualToSize(videoSize,_mediaSession.videoStreamingConfiguration.videoSize)) {
        PLVideoStreamingConfiguration *videoStreamingConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:_mediaSession.videoStreamingConfiguration.expectedSourceVideoFrameRate
            videoMaxKeyframeInterval:_mediaSession.videoStreamingConfiguration.videoMaxKeyframeInterval
            averageVideoBitRate:_mediaSession.videoStreamingConfiguration.averageVideoBitRate
            videoProfileLevel:_mediaSession.videoStreamingConfiguration.videoProfileLevel
            videoEncoderType:_mediaSession.videoStreamingConfiguration.videoEncoderType];
        [self.mediaSession reloadVideoStreamingConfiguration:videoStreamingConfiguration];
    }
}

#pragma mark - buttons event
// 切换摄像头
- (void)switchCamera {
    [_mediaSession toggleCamera];
    _zoomSlider.value = 1.0;
    _zoomSlider.minimumValue = 1.0;
    _zoomSlider.maximumValue = MIN(5, _mediaSession.videoActiveFormat.videoMaxZoomFactor);
}

// 开始/停止推流
- (void)startStream:(UIButton *)button {

    // PLMediaStreamingSession
    if (_mSettings.streamType == 0 || _mSettings.streamType == 1) {
        // 开始/停止 推流
        if (!button.selected) {
            __weak typeof(self) weakSelf = self;
            [_mediaSession startStreamingWithPushURL:_pushURL feedback:^(PLStreamStartStateFeedback feedback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf streamStateAlert:feedback];
                    NSLog(@"[PLStreamViewController] start stream feedback - %lu", (unsigned long)feedback);
                    if (feedback == PLStreamStartStateSuccess) {
                        button.selected = YES;
                    }
                });
            }];
        } else{
            button.selected = NO;
            [_mediaSession stopStreaming];
        }
    }
    
    // PLStreamingSession
    if (_mSettings.streamType == 2 || _mSettings.streamType == 3) {
        // 开始/停止 推流
        if (!button.selected) {
            // 开始外部数据导入
            if (_assetReader) {
                [self startPushBuffer];
                __weak typeof(self) weakSelf = self;
                [_streamSession startWithPushURL:_pushURL feedback:^(PLStreamStartStateFeedback feedback) {
                    [weakSelf streamStateAlert:feedback];
                    if (feedback == PLStreamStartStateSuccess) {
                        button.selected = YES;
                    }
                }];
            // 启动录屏
            } else{
                [self startScreenRecorder];
            }
        } else{
            // 停止外部数据导入
            if (_assetReader) {
                button.selected = NO;
                [_streamSession stop];
                [self stopPushBuffer];
            // 停止录屏
            } else{
                [self stopScreenRecorder];
            }
        }
    }
}

// 发送 SEI
- (void)pushSEIData:(UIButton *)button {
    if (_mediaSession && _mediaSession.isStreamingRunning) {
        PLInputTextView *textInputView = [[PLInputTextView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH/2 - 125, KSCREEN_HEIGHT/2 - 80, 250, 140) view:self.view];
        textInputView.delegate = self;
    } else{
        if (_mediaSession) {
            [self presentViewAlert:@"请先开始推流！"];
        }
    }
    if (_streamSession && _streamSession.isRunning) {
        PLInputTextView *textInputView = [[PLInputTextView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH/2 - 125, KSCREEN_HEIGHT/2 - 80, 350, 140) view:self.view];
        textInputView.delegate = self;
    } else{
        if (_streamSession) {
            [self presentViewAlert:@"请先开始推流！"];
        }
    }
}

// 预览视图缩放
- (void)zoomVideo:(UISlider *)slider {
    _mediaSession.videoZoomFactor = slider.value;
}

// 刷新编码帧率，需要根据目标 expectedSourceVideoFrameRate 调整的，请按照如下实现方式
- (void)reloadVideoFPS:(UIButton *)reload {
    PLVideoStreamingConfiguration *videoStreamingConfiguration = _mSettings.videoStreamConfiguration;
    videoStreamingConfiguration.expectedSourceVideoFrameRate = 15;
    videoStreamingConfiguration.videoMaxKeyframeInterval = 45;
    if (_mediaSession && _mediaSession.isStreamingRunning) {
        [_mediaSession reloadVideoStreamingConfiguration:videoStreamingConfiguration];
        _mediaSession.dynamicFrameEnable = YES;
    }
    if (_streamSession && _streamSession.isRunning) {
        [_streamSession reloadVideoStreamingConfiguration:videoStreamingConfiguration];
        _streamSession.dynamicFrameEnable = YES;
    }
}

#pragma mark - PLInputTextViewDelegate

- (void)inputTextView:(PLInputTextView *)inputTextView didClickIndex:(NSInteger)index text:(nonnull NSString *)text {
    if (index == 1) {
        if (_mediaSession) {
            [_mediaSession pushSEIMessage:text repeat:1];
        } else{
            [_streamSession pushSEIMessage:text repeat:1];
        }
        if (text.length != 0 && text) {
            [self presentViewAlert:@"插入 SEI 成功，该功能需搭配支持 SEI 的播放器方可验证！"];
        }
    }
}

#pragma mark - PLStreamingSessionDelegate
// 流状态发生变化的回调
- (void)streamingSession:(PLStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.streamLabel.text = StreamState[state];
        NSLog(@"[PLStreamViewController] 流状态: %@", StreamState[state]);
    });
}

// 失去连接发生错误的回调
- (void)streamingSession:(PLStreamingSession *)session didDisconnectWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[PLStreamViewController] 失去连接发生错误: error %@, code %ld", error.localizedDescription, error.code);
    });
}

// 流信息更新的回调
- (void)streamingSession:(PLStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.statusLabel.text = [NSString stringWithFormat:@" video %.1f fps\n audio %.1f fps\nvideo %.1f bps\naudio %.1f bps\ntotal bitrate %.1f kbps",status.videoFPS, status.audioFPS, status.videoBitrate, status.audioBitrate, status.totalBitrate/1000];
        NSLog(@"[PLStreamViewController] PLStreamStatus 的信息: video FPS %.1f, audio FPS %.1f, video Bps %.1f, audio Bps %.1f, total bitrate %.1f", status.videoFPS, status.audioFPS, status.videoBitrate, status.audioBitrate, status.totalBitrate);
    });
}

#pragma mark - 外部数据导入的相关操作
- (void)initAssetReader {
    _frameRate = 15;
    _lock = [[NSLock alloc] init];
    _assetReader = [[PLAssetReader alloc] initWithURL:self.mediaURL frameRate:_frameRate stereo:NO];
    int width = 0;
    int heigit = 0;
    float frameRate = 0;
    CMTime duration = kCMTimeZero;
    [_assetReader getVideoInfo:&width height:&heigit frameRate:&frameRate duration:&duration];
    _frameRate = frameRate;
}
// 音视频推流速率和音视频同步策略:
// 开始推流的时候，获取一个当前绝对时间、作为开始推流时间点。在获取推流数据 CMSampleBuffer 之后，再获取一个当前绝对时间，
// 与推流开始的时候时间点做时间差，得到一个时长，这个时长就是音视频数据应该推的时长，
// 视频数据
- (void)videoPushProc {
    @autoreleasepool {
        while (self.isRunning) {
            [self.lock lock];
            CMSampleBufferRef sample = [self.assetReader readVideoSampleBuffer];
            if (!sample) {
                // 没有获取到 sample 被认为是推流文件到尾端，开启一个新的推流循环
                [self.assetReader seekTo:kCMTimeZero frameRate:15];
            }
            [self.lock unlock];
            
            if (sample) {
                [_streamSession pushVideoSampleBuffer:sample];
                
                // Do this outside of the video processing queue to not slow that down while waiting
                CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sample);
                CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
                CFAbsoluteTime duration = CMTimeGetSeconds(currentSampleTime);
                if (duration > currentActualTime - _startActualFrameTime) {
                    [NSThread sleepForTimeInterval:duration - (currentActualTime - _startActualFrameTime)];
                }
                CFRelease(sample);
            }
        }
    }
}
// 音频数据
- (void)audioPushProc {
    @autoreleasepool {
        while (self.isRunning) {
            [self.lock lock];
            CMSampleBufferRef sample = [self.assetReader readAudioSampleBuffer];
            if (!sample) {
                [self.assetReader seekTo:kCMTimeZero frameRate:15];
                [self resetTime];
            }
            [self.lock unlock];
            if (sample) {
                [_streamSession pushAudioSampleBuffer:sample];
                
                CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sample);
                CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
                CFAbsoluteTime duration = CMTimeGetSeconds(currentSampleTime);
                if (duration > currentActualTime - _startActualFrameTime) {
                    [NSThread sleepForTimeInterval:duration - (currentActualTime - _startActualFrameTime)];
                }
                CFRelease(sample);
            }
        }
    }
}
// 开始推 buffer
- (void)startPushBuffer {
    [self.lock lock];
    if (self.isRunning) {
        [self.lock unlock];
        return;
    }
    self.running = YES;
    [self.assetReader seekTo:kCMTimeZero frameRate:_frameRate];
    [self resetTime];
    if (_assetReader.hasVideo) {
        [NSThread detachNewThreadSelector:@selector(videoPushProc) toTarget:self withObject:nil];
    } else {
        NSLog(@"[PLStreamViewController] media with no video data!");
    }
    if (_assetReader.hasAudio) {
        [NSThread detachNewThreadSelector:@selector(audioPushProc) toTarget:self withObject:nil];
    } else {
        NSLog(@"[PLStreamViewController] media with no audio data!");
    }
    [self.lock unlock];
}
// 停止推 buffer
- (void)stopPushBuffer {
    self.running = NO;
}
// 重置时间戳
-(void)resetTime {
    _startActualFrameTime = CFAbsoluteTimeGetCurrent();
}

#pragma mark - 录屏相关
- (void)startScreenRecorder {
    if (_needRecordSystem) {
        // 使用 RPSystemBroadcastPickerView 展示启动 view
        if (@available(iOS 12.0, *)) {
            // iOS 12.0 以上
            _broadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
            _broadcastPickerView.showsMicrophoneButton = YES;
            // 对使用 upload extension 的 bundle id，必须要填写对
            _broadcastPickerView.preferredExtension = PLPreferredExtension;
            [self.view addSubview:_broadcastPickerView];
            _broadcastPickerView.center = CGPointMake(self.view.center.x, self.view.center.y + 100);
        } else{
            if (@available(iOS 11.0, *)) {
                // iOS 11.0 以上录制手机屏幕
                // 1）首先在设置-控制中心-自定控制，添加屏幕录制
                // 2）然后上拉调出控制中心，长按录制按钮，调出录屏控制面板
                // 3）选择对应直播功能的 Extension 开始
                [self presentViewAlert:@"1）首先在设置-控制中心-自定控制，添加屏幕录制\n2）然后上拉调出控制中心，长按录制按钮，调出录屏控制面板\n3）选择对应直播功能的 Extension 开始"];
            } else{
                // iOS 10.0 上不支持录制手机屏幕
                // 由于 Apple 对 Extension App 严格的内存大小的限制，一旦超过这个阈值（50M）就会引起 Crash
                [self presentViewAlert:@"iOS 10.0 上不支持录制手机屏幕"];
            }
        }
    } else{
        // 可以使用 RPScreenRecorder
        if (@available(iOS 11.0, *)) {
            __weak typeof(self) weakSelf = self;
            [_screenRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"[PLStreamViewController] RPScreenRecorder startCaptureWithHandler, error code %ld description %@", (long)error.code, error.localizedDescription);
                    });
                } else {
                    if (bufferType == RPSampleBufferTypeVideo) {
                        // 这里选择了推 App 的画面内容，也可使用系统相机采集数据去推
                        [weakSelf.streamSession pushVideoSampleBuffer:sampleBuffer];
                    }
                    // 音频推 2 路的话，需要配置 PLAudioStreamingConfiguration 的 inputAudioChannelDescriptions 为 @[kPLAudioChannelApp, kPLAudioChannelMic]
//                    if (bufferType == RPSampleBufferTypeAudioApp) {
//                        [weakSelf.streamSession pushAudioSampleBuffer:sampleBuffer];
//                    }
                    if (bufferType == RPSampleBufferTypeAudioMic) {
                        [weakSelf.streamSession pushAudioSampleBuffer:sampleBuffer];
                    }
                }
            } completionHandler:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        NSLog(@"[PLStreamViewController] RPScreenRecorder completionHandler, error code %ld description %@", (long)error.code, error.localizedDescription);
                    } else {
                        [_streamSession startWithPushURL:_pushURL feedback:^(PLStreamStartStateFeedback feedback) {
                            [weakSelf streamStateAlert:feedback];
                            if (PLStreamStartStateSuccess == feedback) {
                                weakSelf.startButton.selected = YES;
                            }
                        }];
                    }
                });
            }];
        } else{
            // 关于 iOS 10.3.3
            // 注意：1）Extension 中 Info.plist 的 key NSExtensionPointIdentifier 对应的 value 都改为 com.apple.broadcast-services 才能正常在 iOS 10.3.3 的机器上正常运行
            //      2）iOS 11 以上 NSExtensionPointIdentifier 需要分别对应配置为 com.apple.broadcast-services-upload、com.apple.broadcast-services-setupui 才能在屏幕录制的系统控制面板显示
            
            // 调起 RPBroadcastActivityViewController 用 extension 录制
            [self loadBroadcast];
        }
    }
}

- (void)stopScreenRecorder {
    if (_needRecordSystem) {
        // 使用 RPSystemBroadcastPickerView 展示启动 view
        if (@available(iOS 12.0, *)) {
            // iOS 12.0 上录制手机屏幕
        } else{
            if (@available(iOS 11.0, *)) {
                // iOS 11.0 上录制手机屏幕
            } else{
                // iOS 10.0 上不支持录制手机屏幕
            }
        }
    } else{
        // 使用 RPScreenRecorder
        if (@available(iOS 11.0, *)) {
            [_streamSession stop];
            _startButton.selected = NO;
            [_screenRecorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"[PLStreamViewController] RPScreenRecorder stop recording success!");
                } else {
                    NSLog(@"[PLStreamViewController] RPScreenRecorder stop recording, error code %ld description %@", error.code, error.localizedDescription);
                }
            }];
            if (_screenRecorder.isRecording) {
                [_screenRecorder stopCaptureWithHandler:nil];
            }
            
            [_screenRecorder.cameraPreviewView removeFromSuperview];
        }
    }
}

- (void)loadBroadcast {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.qbox"];
    [userDefaults setObject:@(PLStreamStateUnknow) forKey:@"PLReplayStreamState"];
    if (!_broadcastController.isBroadcasting) {
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 11.0, *)) {
            [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithPreferredExtension:PLPreferredExtension handler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        weakSelf.broadcastActivityVC = broadcastActivityViewController;
                        weakSelf.broadcastActivityVC.delegate = weakSelf;
                        [weakSelf presentViewController:weakSelf.broadcastActivityVC animated:YES completion:nil];
                    } else {
                       NSLog(@"[PLStreamViewController] loadBroadcast PreferredExtension, error code %ld description %@", error.code, error.localizedDescription);
                       [weakSelf presentViewAlert:[NSString stringWithFormat:@"loadBroadcast PreferredExtension 无法启动 ReplayKit 录屏，发生错误 code:%ld %@", error.code, error.localizedDescription]];
                    }
                });
            }];
        } else{
            [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        weakSelf.broadcastActivityVC = broadcastActivityViewController;
                        weakSelf.broadcastActivityVC.delegate = weakSelf;
                        [weakSelf presentViewController:weakSelf.broadcastActivityVC animated:YES completion:nil];
                    } else {
                       NSLog(@"[PLStreamViewController] loadBroadcast, error code %ld description %@", error.code, error.localizedDescription);
                       [weakSelf presentViewAlert:[NSString stringWithFormat:@"loadBroadcast 无法启动 ReplayKit 录屏，发生错误 code:%ld %@", error.code, error.localizedDescription]];
                    }
                });
            }];
        }
    } else {
        [self stopReplayLive];
    }
}

- (void)stopReplayLive {
    __weak typeof(self) weakSelf = self;
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf stopScreenRecorder];
            NSLog(@"[PLStreamViewController] stopReplayLive finsh broadcast success!");
        } else {
            NSLog(@"[PLStreamViewController] stopReplayLive, error code %ld description %@", error.code, error.localizedDescription);
        }
    }];
}

// RPBroadcastActivityViewControllerDelegate
- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error {
    [self.broadcastActivityVC dismissViewControllerAnimated:YES completion:nil];

    NSLog(@"[PLStreamViewController] broadcastActivityViewController finsh with broadcast, error code %ld description %@", error.code, error.localizedDescription);
    if (error) {
        [self presentViewAlert:[NSString stringWithFormat:@"结束 broadcast 发生错误 code:%ld %@", error.code, error.localizedDescription]];
    } else{
        self.broadcastController = broadcastController;
        self.broadcastController.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [weakSelf startScreenRecorder];
                } else {
                    NSLog(@"[PLStreamViewController] start broadcast, error code %ld description %@", error.code, error.localizedDescription);
                    [weakSelf presentViewAlert:[NSString stringWithFormat:@"无法启动 ReplayKit 录屏，发生错误 code:%ld %@", error.code, error.localizedDescription]];
                }
            });
        }];
    }
}

// RPBroadcastControllerDelegate
- (void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError *)error {
    NSLog(@"[PLStreamViewController] broadcastController 结束时发生错误 error code %ld description %@", error.code, error.localizedDescription);
    if (error) {
        [self presentViewAlert:[NSString stringWithFormat:@"录屏发生错误 code:%ld %@", error.code, error.localizedDescription]];
    }
}
- (void)broadcastController:(RPBroadcastController *)broadcastController didUpdateBroadcastURL:(NSURL *)broadcastURL {
    NSLog(@"[PLStreamViewController] broadcastController 更新 broadcastURL:%@", broadcastURL);
}
- (void)broadcastController:(RPBroadcastController *)broadcastController didUpdateServiceInfo:(NSDictionary<NSString *,NSObject<NSCoding> *> *)serviceInfo {
    NSLog(@"[PLStreamViewController] broadcastController 更新 serviceInfo:%@", serviceInfo);
}

// RPScreenRecorderDelegate
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(RPPreviewViewController *)previewViewController {
    NSLog(@"[PLStreamViewController] screenRecorder didStopRecordingWithError:code %ld description %@", error.code, error.localizedDescription);
}
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithPreviewViewController:(RPPreviewViewController *)previewViewController error:(NSError *)error {
    NSLog(@"[PLStreamViewController] screenRecorder didStopRecordingWithPreviewViewController error:code %ld description %@", error.code, error.localizedDescription);
}

// 计时器事件
- (void)timingAction:(NSTimer *)timer {
    _timingLabel.text = [NSString stringWithFormat:@"系统 iOS %@\n当前时间: %@", _systemVersion, [self getCurrentTime]];
}

#pragma mark - 退前后台相关处理
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 音频打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    // 系统录屏弹框打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

}
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    // 系统录屏弹框打断
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
// 已经进入后台
- (void)enterBackgroundNotification:(NSNotification *)info {
    if (_mSettings.streamType == 2) {
        // AssetReader 使用了硬解
        // 需要在进入后台的时候，停止推流
        [self stopPushBuffer];
    }
}
// 即将回到前台
- (void)willEnterForegroundNotification:(NSNotification *)info {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_mSettings.streamType == 2 && _streamSession.isRunning) {
            [self startPushBuffer];
        }
    });
}
// 音频打断
- (void)interruptionNotification:(NSNotification *)info {
    AVAudioSessionInterruptionType type =  [info.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeEnded) {
//        [self presentViewAlert:@"音频打断已结束！"];
    } else if ( type == AVAudioSessionInterruptionTypeBegan) {
        [self presentViewAlert:@"音频开始被打断！"];
    }
}
// 系统录屏弹框打断
- (void)willResignNotification:(NSNotification *)info {
//    [self presentViewAlert:@"走了即将进入休眠！"];
}
- (void)didActiveNotification:(NSNotification *)info {
//    [self presentViewAlert:@"已经恢复活跃！"];
}
#pragma mark - 录屏选择
- (void)selectedReplayType {
    // 录制 App 内容，进行推流：
    // 1）iOS 11.0 以上，使用 RPScreenRecorder 直接录制
    // 2）iOS 10.0 上，使用 RPBroadcastController 调起，可对应自己 App 也可对应其他支持 Extension 的 App
    
    // 录制系统全屏，进行推流：
    // 1）iOS 12.0 以上，使用 RPSystemBroadcastPickerView 直接调起
    // 2）iOS 11.0 上，外部系统设置长按录屏
    
    // 弹框询问，录屏 App 内容，还是录制手机全屏
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"录屏选择" message:@"是否录制手机全屏？" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.needRecordSystem = YES;
        weakSelf.startButton.hidden = YES;
        weakSelf.seiButton.hidden = YES;
        [weakSelf startStream:_startButton];
    }];
    [alertViewController addAction:yesAction];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.needRecordSystem = NO;
        weakSelf.startButton.hidden = NO;
        weakSelf.seiButton.hidden = NO;
    }];
    [alertViewController addAction:noAction];

    [self presentViewController:alertViewController animated:YES completion:nil];
}

#pragma mark - alert view
- (void)presentViewAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 流状态的统一提示
- (void)streamStateAlert:(PLStreamStartStateFeedback)feedback {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (feedback) {
            case PLStreamStartStateSuccess:
                [weakSelf presentViewAlert:@"成功开始推流!"];
                break;
            case PLStreamStartStateSessionUnknownError:
                [weakSelf presentViewAlert:@"发生未知错误无法启动!"];
                break;
            case PLStreamStartStateSessionStillRunning:
                [weakSelf presentViewAlert:@"已经在运行中，无需重复启动!"];
                break;
            case PLStreamStartStateStreamURLUnauthorized:
                [weakSelf presentViewAlert:@"当前的 StreamURL 没有被授权!"];
                break;
            case PLStreamStartStateSessionConnectStreamError:
                [weakSelf presentViewAlert:@"建立 socket 连接错误!"];
                break;
            case PLStreamStartStateSessionPushURLInvalid:
                [weakSelf presentViewAlert:@"当前传入的 pushURL 无效!"];
                break;
            default:
                break;
        }
    });
}

#pragma mark - 获取当前时间
- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSDate *datenow = [NSDate date];
    NSString *nowtimeStr = [formatter stringFromDate:datenow];
    return nowtimeStr;
}

#pragma mark - save image to phtoto album delegate
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"亲，截图已成功保存至相册～" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [self presentViewController:alertVc animated:YES completion:^{
        [weakSelf performSelector:@selector(dismissView) withObject:nil afterDelay:3];
    }];
}

#pragma mark - 返回上一界面
- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
