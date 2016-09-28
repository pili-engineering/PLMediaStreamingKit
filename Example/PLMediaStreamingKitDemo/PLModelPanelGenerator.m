//
//  PLModelPanelGenerator.m
//  PLCameraStreamingKitDemo
//
//  Created by TaoZeyu on 16/5/27.
//  Copyright © 2016年 Pili. All rights reserved.
//

#import "PLModelPanelGenerator.h"
#import "PLStreamingKitDemoUtils.h"

#import "PLMediaStreamingKit.h"

@implementation PLModelPanelGenerator
{
    PLMediaStreamingSession *_streamingSession;
    PLPanelDelegateGenerator *_generator;
    CGPoint _wartmarkOrigin;
}

- (instancetype)initWithMediaStreamingSession:(PLMediaStreamingSession *)streamingSession panelDelegateGenerator:(PLPanelDelegateGenerator *)generator
{
    if (self = [self init]) {
        _streamingSession = streamingSession;
        _wartmarkOrigin = CGPointMake(100, 300);
        _generator = generator;
    }
    return self;
}

- (NSArray *)generate
{
    return @[[self _generateInitConfiguration],
             [self _generateStreamingSessionOperation],
             [self _generateFilter],
            ];
}

- (PLPanelModel *)_generateInitConfiguration
{
    PLPanelModel *model = [[PLPanelModel alloc] initWithTitle:@"Config"];
    
    PLVideoStreamingConfiguration *videoStreamConf = [_streamingSession.videoStreamingConfiguration copy];
    PLAudioCaptureConfiguration *audioCaptureConf = [PLAudioCaptureConfiguration defaultConfiguration];
    PLAudioStreamingConfiguration *audioStreamConf = [PLAudioStreamingConfiguration defaultConfiguration];
    
    __block PLVideoStreamingConfiguration *videoStreamingConfigutationToApply = videoStreamConf;
    __block PLAudioCaptureConfiguration *audioCaptureConfigutationToApply = audioCaptureConf;
    __block PLAudioStreamingConfiguration *audioStreamingConfigutationToApply = audioStreamConf;
    
    __weak PLMediaStreamingSession *wsession = _streamingSession;
    
    PLTitleValueConf *videoFrameRateConf = [PLTitleValueConf confWithValues:@[@5, @15, @20, @24, @30]];
    
    NSMutableArray *sessionPresetTitles = [NSMutableArray arrayWithArray:@[
        @"352x288",
        @"640x480",
        @"1280x720",
        @"1920x1080",
        @"Low",
        @"Medium",
        @"High",
        @"Photo",
        @"InputPriority",
        @"iFrame960x540",
        @"iFrame1280x720",
    ]];
    NSMutableArray *sessionPresetValues = [NSMutableArray arrayWithArray:@[
        AVCaptureSessionPreset352x288,
        AVCaptureSessionPreset640x480,
        AVCaptureSessionPreset1280x720,
        AVCaptureSessionPreset1920x1080,
        AVCaptureSessionPresetLow,
        AVCaptureSessionPresetMedium,
        AVCaptureSessionPresetHigh,
        AVCaptureSessionPresetPhoto,
        AVCaptureSessionPresetInputPriority,
        AVCaptureSessionPresetiFrame960x540,
        AVCaptureSessionPresetiFrame1280x720,
    ]];
    int mediumPresetIndex = 5;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        [sessionPresetTitles insertObject:@"3840x2160" atIndex:4];
        [sessionPresetValues insertObject:AVCaptureSessionPreset3840x2160 atIndex:4];
        mediumPresetIndex = 6;
    }
    PLTitleValueConf *sessionPresetConf = [PLTitleValueConf confWithTitles:sessionPresetTitles
                                                                withValues:sessionPresetValues];
    
    PLTitleValueConf *cameraPositionConf = [PLTitleValueConf confWithTitles:@[
        @"unspecified",
        @"back",
        @"front"]
        withValues:@[
        @(AVCaptureDevicePositionUnspecified),
        @(AVCaptureDevicePositionBack),
        @(AVCaptureDevicePositionFront)
                     ]];
    
    PLTitleValueConf *videoOrientationConf = [PLTitleValueConf confWithTitles:@[
        @"portrait",
        @"portraitUpsideDown",
        @"landscapeRight",
        @"landscapeLeft"
        ]
        withValues:@[
        @(AVCaptureVideoOrientationPortrait),
        @(AVCaptureVideoOrientationPortraitUpsideDown),
        @(AVCaptureVideoOrientationLandscapeRight),
        @(AVCaptureVideoOrientationLandscapeLeft)
        ]];
    
    PLTitleValueConf *profileLevelConf = [PLTitleValueConf confWithTitles:@[
        @"H264Baseline30",
        @"H264Baseline31",
        @"H264Baseline41",
        @"H264BaselineAutoLevel",
        @"H264Main30",
        @"H264Main31",
        @"H264Main32",
        @"H264Main41",
        @"H264MainAutoLevel",
        @"H264High40",
        @"H264High41",
        @"H264HighAutoLevel",
    ]
    withValues:@[
        AVVideoProfileLevelH264Baseline30,
        AVVideoProfileLevelH264Baseline31,
        AVVideoProfileLevelH264Baseline41,
        AVVideoProfileLevelH264BaselineAutoLevel,
        AVVideoProfileLevelH264Main30,
        AVVideoProfileLevelH264Main31,
        AVVideoProfileLevelH264Main32,
        AVVideoProfileLevelH264Main41,
        AVVideoProfileLevelH264MainAutoLevel,
        AVVideoProfileLevelH264High40,
        AVVideoProfileLevelH264High41,
        AVVideoProfileLevelH264HighAutoLevel
    ]];
    
    PLTitleValueConf *expectedSourceVideoFrameRateConf = [PLTitleValueConf confWithValues:@[@5, @10, @15, @20, @24, @30]];
    
    PLTitleValueConf *videoMaxKeyframeIntervalConf = [PLTitleValueConf confWithValues:@[@15, @30, @45, @72, @90]];
    PLTitleValueConf *averageVideoBitRateConf = [PLTitleValueConf confWithTitleFormat:@"%@Kbps" withValues:@[@256, @512, @768, @1024, @1280, @1536, @2048]];
    
    PLTitleValueConf *channelsPerFrameConf = [PLTitleValueConf confWithTitleFormat:@"%@" withValues:@[@1, @2]];

    PLTitleValueConf *audioBitRateConf = [PLTitleValueConf confWithTitleFormat:@"%@Kbps" withValues:@[@64, @96, @128]];
    PLTitleValueConf *encodedNumberOfChannelsConf = [PLTitleValueConf confWithTitleFormat:@"%@" withValues:@[@1, @2]];
    
    model.attributeModels = @[
                              
        [PLAttributeModel titleAttributeModelWithTitle:@">> PLVideoCaptureConfiguration"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"videoFrameRate" withSegements:videoFrameRateConf.titles withDefaultIndex:3 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.videoFrameRate = [videoFrameRateConf unsignedIntegerAt:selectedIndex];
        }],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"sessionPreset" withElements:sessionPresetConf.titles withDefaultIndex:mediumPresetIndex withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.sessionPreset = [sessionPresetConf stringAt:selectedIndex];
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"previewMirrorFrontFacing" withSegements:@[@"YES", @"NO"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.previewMirrorFrontFacing = (selectedIndex != 1);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"streamMirrorFrontFacing" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.streamMirrorFrontFacing = (selectedIndex != 1);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"previewMirrorRearFacing" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.previewMirrorRearFacing = (selectedIndex != 1);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"streamMirrorRearFacing" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.streamMirrorRearFacing = (selectedIndex != 1);
        }],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"cameraPositon" withElements:cameraPositionConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.captureDevicePosition = [cameraPositionConf integerAt:selectedIndex];
        }],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"videoOrientation" withElements:videoOrientationConf.titles withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong typeof(wsession) strongSession = wsession;
            strongSession.videoOrientation = [videoOrientationConf integerAt:selectedIndex];
        }],
        
        
        [PLAttributeModel titleAttributeModelWithTitle:@">> PLVideoStreamingConfiguration"],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"videoProfileLevel"
                                            withElements:profileLevelConf.titles
                                        withDefaultIndex:11
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        videoStreamingConfigutationToApply = [wsession.videoStreamingConfiguration copy];
                                        videoStreamingConfigutationToApply.videoProfileLevel = [profileLevelConf stringAt:selectedIndex];
        }],
        [PLAttributeModel
         spinnerAttributeModelWithTitle:@"videoSize"
         withElements:@[@"368x640", @"400x720", @"720x1280", @"1080x1920"]
         withDefaultIndex:0
         withSelectedCallback:^(NSInteger selectedIndex) {
             videoStreamingConfigutationToApply = [wsession.videoStreamingConfiguration copy];
             CGSize videoSize;
             switch (selectedIndex) {
                 case 0:
                     videoSize = CGSizeMake(368, 640);
                     break;
                 case 1:
                     videoSize = CGSizeMake(400, 720);
                     break;
                 case 2:
                     videoSize = CGSizeMake(720, 1280);
                     break;
                 case 3:
                     videoSize = CGSizeMake(1080, 1920);
                     break;
                 default:
                     break;
             }
             videoStreamingConfigutationToApply.videoSize = videoSize;
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"expectedSourceVideoFrameRate"],
        [PLAttributeModel segmentAttributeModelWithTitle:@""
                                           withSegements:expectedSourceVideoFrameRateConf.titles
                                        withDefaultIndex:4
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        videoStreamingConfigutationToApply = [wsession.videoStreamingConfiguration copy];
                                        videoStreamingConfigutationToApply.expectedSourceVideoFrameRate = [expectedSourceVideoFrameRateConf unsignedIntegerAt:selectedIndex];
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"videoMaxKeyframeInterval"],
        [PLAttributeModel segmentAttributeModelWithTitle:@""
                                           withSegements:videoMaxKeyframeIntervalConf.titles
                                        withDefaultIndex:3
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        videoStreamingConfigutationToApply = [wsession.videoStreamingConfiguration copy];
                                        videoStreamingConfigutationToApply.videoMaxKeyframeInterval = [videoMaxKeyframeIntervalConf unsignedIntegerAt:selectedIndex];
        }],
        [PLAttributeModel titleAttributeModelWithTitle:@"averageVideoBitRate"],
        [PLAttributeModel spinnerAttributeModelWithTitle:@""
                                           withElements:averageVideoBitRateConf.titles
                                        withDefaultIndex:2
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        videoStreamingConfigutationToApply = [wsession.videoStreamingConfiguration copy];
                                        videoStreamingConfigutationToApply.averageVideoBitRate = [averageVideoBitRateConf unsignedIntegerAt:selectedIndex] * 1024;
        }],
        
        
        [PLAttributeModel titleAttributeModelWithTitle:@">> PLAudioCaptureConfiguration"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"channelsPerFrame"
                                           withSegements:channelsPerFrameConf.titles
                                        withDefaultIndex:0
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        audioCaptureConfigutationToApply = [wsession.audioCaptureConfiguration copy];
                                        audioCaptureConfigutationToApply.channelsPerFrame = [channelsPerFrameConf unsignedIntegerAt:selectedIndex];
                                    }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@">> PLAudioStreamingConfiguration"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"audioBitRate"
                                           withSegements:audioBitRateConf.titles
                                        withDefaultIndex:1
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        audioStreamingConfigutationToApply = [wsession.audioStreamingConfiguration copy];
                                        audioStreamingConfigutationToApply.audioBitRate = [audioBitRateConf intAt:selectedIndex];
                                    }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"encodedNumberOfChannels"
                                           withSegements:encodedNumberOfChannelsConf.titles
                                        withDefaultIndex:0
                                    withSelectedCallback:^(NSInteger selectedIndex) {
                                        audioStreamingConfigutationToApply = [wsession.audioStreamingConfiguration copy];
                                        audioStreamingConfigutationToApply.encodedNumberOfChannels = [encodedNumberOfChannelsConf unsignedIntAt:selectedIndex];
                                    }],
            ];
    [model setOnAnyAttributeValueChanged:^(PLAttributeModel *attributeModel) {
        [wsession reloadVideoStreamingConfiguration:videoStreamingConfigutationToApply];
    }];
    return model;
}

- (PLPanelModel *)_generateStreamingSessionOperation
{
    PLPanelModel *model = [[PLPanelModel alloc] initWithTitle:@"Session"];
    __weak PLMediaStreamingSession *wsession = _streamingSession;
    
    __block PLAudioPlayer *audioPlayer;
    __block NSString *audioPath;
    __block float audioVolume = 0.1;
    
    PLTitleValueConf *videoOrientationConf = [PLTitleValueConf confWithTitles:@[
        @"Portrait",
        @"PortraitUpsideDown",
        @"LandscapeRight",
        @"LandscapeLeft",
    ] withValues:@[
        @(AVCaptureVideoOrientationPortrait),
        @(AVCaptureVideoOrientationPortraitUpsideDown),
        @(AVCaptureVideoOrientationLandscapeRight),
        @(AVCaptureVideoOrientationLandscapeLeft),
    ]];
    PLTitleValueConf *statusUpdateIntervalConf = [PLTitleValueConf confWithValues:@[@1, @3, @5, @15, @30]];
    PLTitleValueConf *fillModeConf = [PLTitleValueConf confWithTitles:@[
        @"Stretch",
        @"AspectRatio",
        @"AspectRatioAndFill",
    ]
    withValues:@[
        @(PLVideoFillModeStretch),
        @(PLVideoFillModePreserveAspectRatio),
        @(PLVideoFillModePreserveAspectRatioAndFill),
    ]];
    
    PLTitleValueConf *minVideoBitRateConf = [PLTitleValueConf confWithTitles:@[
        @"disable",
        @"150Kbps",
        @"200Kbps",
        @"400Kbps",
        @"600Kbps",
        @"800Kbps",
        @"1000Kbps"] withValues:@[
        @0,
        @(150*1000),
        @(200*1000),
        @(400*1000),
        @(600*1000),
        @(800*1000),
        @1000]];

    PLTitleValueConf *thresholdConf = [PLTitleValueConf confWithValues:@[@0, @0.25, @0.5, @0.75, @1]];
    PLTitleValueConf *maxCountConf = [PLTitleValueConf confWithValues:@[@0,  @150, @300, @450, @600]];
    
    PLTitleValueConf *musicNameConf = [PLTitleValueConf confWithTitles:@[@"M1", @"M2",
                                                                         @"M3", @"M4", @"M5"]
                                                            withValues:@[@"TestMusic1.mp3",
                                                                         @"TestMusic2.wav",
                                                                         @"TestMusic3.wav",
                                                                         @"TestMusic4.mp3",
                                                                         @"TestMusic5.mp3",]];
    
    PLTitleValueConf *devicePositionConf = [PLTitleValueConf confWithTitles:@[
        @"unspecified",
        @"back",
        @"front",
    ] withValues:@[
        @(AVCaptureDevicePositionUnspecified),
        @(AVCaptureDevicePositionBack),
        @(AVCaptureDevicePositionFront),
    ]];
    PLTitleValueConf *inputGainConf = [PLTitleValueConf confWithValues:@[@0, @0.25, @0.5, @0.75, @1]];
    
    model.attributeModels = @[
                              
        [PLAttributeModel titleAttributeModelWithTitle:@"StreamingSessionOperation"],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"videoOrientation" withElements:videoOrientationConf.titles withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.videoOrientation = [videoOrientationConf integerAt:selectedIndex];
        }],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"statusUpdateInterval" withElements:statusUpdateIntervalConf.titles withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.statusUpdateInterval = [statusUpdateIntervalConf doubleAt:selectedIndex];
        }],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"fillMode" withElements:fillModeConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.fillMode = [fillModeConf intAt:selectedIndex];
        }],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"adaptiveRateControl" withElements:minVideoBitRateConf.titles withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            if (!selectedIndex) {
                [wsession disableAdaptiveBitrateControl];
            } else {
                [wsession enableAdaptiveBitrateControlWithMinVideoBitRate:[minVideoBitRateConf unsignedIntegerAt:selectedIndex]];
            }
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"dynamicFrameEnable" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.dynamicFrameEnable = !selectedIndex;
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"autoReconnectEnable" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.autoReconnectEnable = !selectedIndex;
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"monitorNetworkStateEnable" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.monitorNetworkStateEnable = !selectedIndex;
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"Buffer"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"threshold" withSegements:thresholdConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.threshold = [thresholdConf doubleAt:selectedIndex];
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"maxCount" withSegements:maxCountConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.maxCount = [thresholdConf unsignedIntegerAt:selectedIndex];
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"idleTimerDisable" withSegements:@[@"YES", @"NO"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.idleTimerDisable = (selectedIndex == 0);
        }],
        [PLAttributeModel titleAttributeModelWithTitle:@"MicrophoneSource"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"muted" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.muted = (selectedIndex == 0);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"playback" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.playback = (selectedIndex == 0);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"inputGain" withSegements:inputGainConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.inputGain = [inputGainConf doubleAt:selectedIndex];
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"AudioEffect"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:@[@"None", @"Low", @"Medium", @"Height"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            
            NSArray<PLAudioEffectConfiguration *> *configs;
            switch (selectedIndex) {
                case 0:
                    configs = @[];
                    break;
                    
                case 1:
                    configs = @[[PLAudioEffectModeConfiguration reverbLowLevelModeConfiguration]];
                    break;
                    
                case 2:
                    configs = @[[PLAudioEffectModeConfiguration reverbMediumLevelModeConfiguration]];
                    break;
                    
                case 3:
                    configs = @[[PLAudioEffectModeConfiguration reverbHeightLevelModeConfiguration]];
                    break;
            }
            wsession.audioEffectConfigurations = configs;
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"PLAudioPlayer"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"open player" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            if (selectedIndex == 0) {
                audioPath = audioPath ?: [[NSBundle mainBundle] pathForResource:@"TestMusic1" ofType:@"mp3"];
                audioPlayer = [wsession audioPlayerWithFilePath:audioPath];
                audioPlayer.volume = audioVolume;
                [audioPlayer play];
            } else {
                [wsession closeCurrentAudio];
                audioPlayer = nil;
            }
        }],
        [PLAttributeModel buttonAttributeModelWithTitles:@[@"play", @"pause"] withTapCallback:^(NSUInteger tapedIndex) {
            if (audioPlayer) {
                if (tapedIndex == 0) {
                    [audioPlayer play];
                } else {
                    [audioPlayer pause];
                }
            }
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"files" withSegements:musicNameConf.titles withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            NSString *fileName = [musicNameConf stringAt:selectedIndex];
            NSArray *arr = [fileName componentsSeparatedByString:@"."];
            audioPath = [[NSBundle mainBundle] pathForResource:arr[0] ofType:arr[1]];
            if (audioPlayer) {
                audioPlayer.audioFilePath = audioPath;
            }
        }],
        [PLAttributeModel sliderAttributeModelWithTitle:@"volume" withDefaultValue:0.1 withValueChangedCallback:^(float value) {
            audioVolume = value;
            if (audioPlayer) {
                audioPlayer.volume = value;
            }
        }],
        [PLAttributeModel sliderAttributeModelWithTitle:@"seek" withDefaultValue:0 withValueChangedCallback:^(float value) {
            if (audioPlayer) {
                audioPlayer.audioDidPlayedRate = value;
            }
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"CameraSource"],
        [PLAttributeModel spinnerAttributeModelWithTitle:@"captureDevicePosition" withElements:devicePositionConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.captureDevicePosition = [devicePositionConf integerAt:selectedIndex];
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"torchOn" withSegements:@[@"YES", @"NO"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.torchOn = (selectedIndex == 0);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"continuousAutofocusEnable" withSegements:@[@"YES", @"NO"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.continuousAutofocusEnable = (selectedIndex == 0);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"touchToFocusEnable" withSegements:@[@"YES", @"NO"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.touchToFocusEnable = (selectedIndex == 0);
        }],
        [PLAttributeModel segmentAttributeModelWithTitle:@"smoothAutoFocusEnabled" withSegements:@[@"YES", @"NO"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.smoothAutoFocusEnabled = (selectedIndex == 0);
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"Application"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"idleTimerDisable" withSegements:@[@"YES", @"NO"] withDefaultIndex:0 withSelectedCallback:^(NSInteger selectedIndex) {
            wsession.idleTimerDisable = (selectedIndex == 0);
        }],
    ];
    return model;
}

- (PLPanelModel *)_generateFilter
{
    PLPanelModel *model = [[PLPanelModel alloc] initWithTitle:@"Filter"];
    __weak PLMediaStreamingSession *wsession = _streamingSession;
    __weak PLPanelDelegateGenerator *wDelegateGenerator = _generator;
    
    __block PLAttributeModel *beautifyModel = nil;
    __block PLAttributeModel *whitenModel = nil;
    __block PLAttributeModel *reddenModel = nil;
    
    PLTitleValueConf *beautifyConf = [PLTitleValueConf confWithValues:@[@0, @0.25, @0.5, @0.75, @1]];
    PLTitleValueConf *whitenConf = [PLTitleValueConf confWithValues:@[@0, @0.25, @0.5, @0.75, @1]];
    PLTitleValueConf *reddenConf = [PLTitleValueConf confWithValues:@[@0, @0.25, @0.5, @0.75, @1]];

    
    model.attributeModels = @[
        [PLAttributeModel titleAttributeModelWithTitle:@"waterMark"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:@[@"七牛", @"小奇1", @"小奇2", @"清空"] withDefaultIndex:3 withSelectedCallback:^(NSInteger selectedIndex) {
            UIImage *image = nil;
            switch (selectedIndex) {
                case 0:
                    image = [UIImage imageNamed:@"qiniu.png"];
                    break;
                case 1:
                    image = [UIImage imageNamed:@"xiaoqi1.png"];
                    break;
                case 2:
                    image = [UIImage imageNamed:@"xiaoqi2.png"];
                    break;
                default:
                    break;
            }
            __strong PLMediaStreamingSession *strongSession = wsession;
            if (image) {
                [strongSession setWaterMarkWithImage:image position:CGPointMake(100, 100)];
            } else {
                [strongSession clearWaterMark];
            }
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"beautyFilter"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:@[@"ON", @"OFF"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong PLMediaStreamingSession *strongSession = wsession;
            [strongSession setBeautifyModeOn:!selectedIndex];
            [beautifyModel reset];
            [whitenModel reset];
            [reddenModel reset];
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"beautify"],
        beautifyModel = [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:beautifyConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong PLMediaStreamingSession *strongSession = wsession;
            [strongSession setBeautify:[beautifyConf doubleAt:selectedIndex]];
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"whiten"],
        whitenModel = [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:whitenConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong PLMediaStreamingSession *strongSession = wsession;
            [strongSession setWhiten:[beautifyConf doubleAt:selectedIndex]];
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"redden"],
        reddenModel = [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:reddenConf.titles withDefaultIndex:2 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong PLMediaStreamingSession *strongSession = wsession;
            [strongSession setRedden:[beautifyConf doubleAt:selectedIndex]];
        }],
        
        [PLAttributeModel titleAttributeModelWithTitle:@"customVideoProcess"],
        [PLAttributeModel segmentAttributeModelWithTitle:@"" withSegements:@[@"ON", @"OFF"] withDefaultIndex:1 withSelectedCallback:^(NSInteger selectedIndex) {
            __strong PLPanelDelegateGenerator *strongGenerator = wDelegateGenerator;
            strongGenerator.needProcessVideo = !selectedIndex;
        }],
    ];
    return model;
}

@end
