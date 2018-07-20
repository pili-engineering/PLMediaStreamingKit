//
//  PLStreamingSessionConstructor.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/24.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import "PLStreamingSessionConstructor.h"

@implementation PLStreamingSessionConstructor
{
    PLMediaStreamingSession *_session;
    PLAudioCaptureConfiguration *_audioCaptureConfiguration;
}

- (instancetype)initWithAudioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
{
    if (self = [self init]) {
        _audioCaptureConfiguration = audioCaptureConfiguration;
    }
    return self;
}

- (PLMediaStreamingSession *)streamingSession
{
    [self _createStreamingSessionWithSream:nil];
    return _session;
}

- (PLMediaStreamingSession *)_createStreamingSessionWithSream:(PLStream *)stream
{
    CGSize videoSize = CGSizeMake(368 , 640);
    
    PLVideoCaptureConfiguration *videoCaptureConfiguration = [[PLVideoCaptureConfiguration alloc]initWithVideoFrameRate:24 sessionPreset:AVCaptureSessionPresetMedium previewMirrorFrontFacing:YES previewMirrorRearFacing:NO streamMirrorFrontFacing:NO streamMirrorRearFacing:NO cameraPosition:AVCaptureDevicePositionFront videoOrientation:AVCaptureVideoOrientationPortrait];
    PLVideoStreamingConfiguration *videoStreamConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:24 videoMaxKeyframeInterval:72 averageVideoBitRate:768 * 1024 videoProfileLevel:AVVideoProfileLevelH264HighAutoLevel videoEncoderType:PLH264EncoderType_AVFoundation];
    PLAudioStreamingConfiguration *audioSreamConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    _session = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration
                                                     audioCaptureConfiguration:_audioCaptureConfiguration
                                                   videoStreamingConfiguration:videoStreamConfiguration
                                                   audioStreamingConfiguration:audioSreamConfiguration
                                                                        stream:stream];
    return _session;
}

@end
