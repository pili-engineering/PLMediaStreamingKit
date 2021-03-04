//
//  BroadcastManager.h
//  PLReplaykitExtension
//
//  Created by 冯文秀 on 2020/3/23.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

@interface BroadcastManager : NSObject

@property (nonatomic, strong) PLStreamingSession *session;

+ (instancetype)createBroadcastManagerWithVideoSize:(CGSize)videoSize streamingURL:(NSString *)streamingURL;
+ (instancetype)sharedBroadcastManager;
- (PLStreamState)streamState;

- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer withChannelID:(const NSString *)channelID;
- (void)restartStreaming;
- (void)stopStreaming;

@end
