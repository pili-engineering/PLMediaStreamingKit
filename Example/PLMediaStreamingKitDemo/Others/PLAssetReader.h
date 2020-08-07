//
//  PLAssetReader.h
//  PLMediaStreamingKitDemo
//
//  Created by hxiongan on 2018/8/22.
//  Copyright © 2018年 hxiongan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PLAssetReader : NSObject


@property (nonatomic, readonly) BOOL hasAudio;
@property (nonatomic, readonly) BOOL hasVideo;

- (instancetype)initWithURL:(NSURL *)url frameRate:(NSUInteger)frameRate stereo:(BOOL)isStereo;

- (void)seekTo:(CMTime)time frameRate:(NSUInteger)frameRate;

- (void)getVideoInfo:(int *)width height:(int *)height frameRate:(float *)fps duration:(CMTime *)duration;

- (CMSampleBufferRef)readVideoSampleBuffer;

- (CMSampleBufferRef)readAudioSampleBuffer;;



@end
