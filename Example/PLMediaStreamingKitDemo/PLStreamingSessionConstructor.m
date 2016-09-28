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
    NSURL *_streamCloudURL;
    PLMediaStreamingSession *_session;
}

- (instancetype)initWithStreamCloudURL:(NSURL *)streamCloudURL
{
    if (self = [self init]) {
        _streamCloudURL = streamCloudURL;
    }
    return self;
}

- (PLMediaStreamingSession *)streamingSession
{
    [self _createStreamingSessionWithSream:nil];
    [self _generateStreamURLFromServerWithURL:_streamCloudURL];
    return _session;
}

- (void)_generateStreamURLFromServerWithURL:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil || response == nil || data == nil) {
            NSLog(@"get play json faild, %@, %@, %@", error, response, data);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self _generateStreamURLFromServerWithURL:url];
            });
            return;
        }
        
        NSURL *streamURL = [NSURL URLWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"streamURL" message:streamURL.absoluteString delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        if ([self.delegate respondsToSelector:@selector(PLStreamingSessionConstructor:didGetStreamURL:)]) {
            [self.delegate PLStreamingSessionConstructor:self didGetStreamURL:streamURL];
        }
    }];
    [task resume];
}

- (PLMediaStreamingSession *)_createStreamingSessionWithSream:(PLStream *)stream
{
    CGSize videoSize = CGSizeMake(368 , 640);
    
    PLVideoCaptureConfiguration *videoCaptureConfiguration = [[PLVideoCaptureConfiguration alloc]initWithVideoFrameRate:24 sessionPreset:AVCaptureSessionPresetMedium previewMirrorFrontFacing:YES previewMirrorRearFacing:NO streamMirrorFrontFacing:NO streamMirrorRearFacing:NO cameraPosition:AVCaptureDevicePositionFront videoOrientation:AVCaptureVideoOrientationPortrait];
    PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    PLVideoStreamingConfiguration *videoStreamConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:24 videoMaxKeyframeInterval:72 averageVideoBitRate:768 * 1024 videoProfileLevel:AVVideoProfileLevelH264HighAutoLevel];
    PLAudioStreamingConfiguration *audioSreamConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    _session = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration
                                                     audioCaptureConfiguration:audioCaptureConfiguration
                                                   videoStreamingConfiguration:videoStreamConfiguration
                                                   audioStreamingConfiguration:audioSreamConfiguration
                                                                        stream:stream];
    return _session;
}

@end
