//
//  BroadcastManager.m
//  PLReplaykitExtension
//
//  Created by 冯文秀 on 2020/3/23.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "BroadcastManager.h"
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

@interface BroadcastManager ()
<
PLStreamingSessionDelegate
>

@end

@implementation BroadcastManager

static BroadcastManager *_instance;

+ (instancetype)sharedBroadcastManager {
    return _instance;
}

+ (instancetype)createBroadcastManagerWithVideoSize:(CGSize)videoSize streamingURL:(NSString *)streamingURL {
    _instance = [[BroadcastManager alloc] initWithVideoSize:videoSize streamingURL:streamingURL];
    return _instance;
}

- (instancetype)initWithVideoSize:(CGSize)videoSize streamingURL:(NSString *)streamingURL
{
    if (self = [super init]) {
        [PLStreamingEnv initEnv];
        [PLStreamingEnv enableFileLogging];
        [PLStreamingEnv setLogLevel:PLStreamLogLevelDebug];
        
        NSLog(@"%@", PLMediaStreamingSession.versionInfo);
        
//        [PLStreamingEnv setLogLevel:PLStreamLogLevelDebug];
//        [PLStreamingEnv enableFileLogging];
        
        PLVideoStreamingConfiguration *videoConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:24 videoMaxKeyframeInterval:72 averageVideoBitRate:1000*1024 videoProfileLevel:AVVideoProfileLevelH264HighAutoLevel videoEncoderType:PLH264EncoderType_AVFoundation];
        PLAudioStreamingConfiguration *audioConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
        audioConfiguration.encodedAudioSampleRate = PLStreamingAudioSampleRate_44100Hz;
        audioConfiguration.inputAudioChannelDescriptions = @[kPLAudioChannelApp, kPLAudioChannelMic];
        audioConfiguration.audioEncoderType = PLAACEncoderType_iOS_AAC;
        
        self.session = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:videoConfiguration
                                                           audioStreamingConfiguration:audioConfiguration
                                                                                stream:nil];
        self.session.autoReconnectEnable = YES;
        self.session.connectionInterruptionHandler = ^(NSError *error) {
            return YES;
        };
        self.session.connectionChangeActionCallback = ^(PLNetworkStateTransition transition) {
            return YES;
        };
        [self.session enableAdaptiveBitrateControlWithMinVideoBitRate:500 * 1024];
        self.session.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.session startWithPushURL:[NSURL URLWithString:streamingURL] feedback:^(PLStreamStartStateFeedback feedback) {
                if (PLStreamStartStateSuccess == feedback) {
                    NSLog(@"[PLReplaykitExtension] streaming connected successfully");
                } else {
                    NSLog(@"[PLReplaykitExtension] stream failed to connect");
                }
            }];
        });
    }
    return self;
}

- (PLStreamState)streamState {
    return self.session.streamState;
}

- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self.session pushVideoSampleBuffer:sampleBuffer];
}

- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self.session pushAudioSampleBuffer:sampleBuffer];
}

- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer withChannelID:(const NSString *)channelID {
    [self.session pushAudioSampleBuffer:sampleBuffer withChannelID:channelID completion:nil];
}

- (void)restartStreaming {
    [self.session restartWithFeedback:^(PLStreamStartStateFeedback feedback) {
        if (PLStreamStartStateSuccess == feedback) {
            NSLog(@"[PLReplaykitExtension] stream restarted successfully");
        }
    }];
}

- (void)stopStreaming {
    [self.session destroy];
    NSLog(@"[PLReplaykitExtension] stream stopped");
}


#pragma mark - PLStreamingSessionDelegate
- (void)streamingSession:(PLStreamingSession *)session didDisconnectWithError:(NSError *)error {
    NSLog(@"[PLReplaykitExtension] streaming error : %@", error);
}

- (void)streamingSession:(PLStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    NSLog(@"[PLReplaykitExtension] stream state did change to: %ld", (long)state);
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.qbox"];
    [userDefaults setObject:@(state) forKey:@"PLReplayStreamState"];
    [userDefaults synchronize];
}

- (void)streamingSession:(PLStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status {
    NSLog(@"[PLReplaykitExtension] stream status updated: %@", status);
}

@end
