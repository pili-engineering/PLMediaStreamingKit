//
//  PLAssetReader.m
//  PLMediaStreamingKitDemo
//
//  Created by hxiongan on 2018/8/22.
//  Copyright © 2018年 hxiongan. All rights reserved.
//

#import "PLAssetReader.h"

@interface PLAssetReader ()

@property (strong, nonatomic) AVAsset *inputAsset;
@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetReaderVideoCompositionOutput *videoReaderOutput;
@property (strong, nonatomic) AVAssetReaderTrackOutput *audioReaderOutput;
@property (assign, nonatomic) CMTime startTime;

@property (assign, nonatomic) NSUInteger frameRate;

@property (assign, nonatomic) NSUInteger numberOfChannels;

@end

@implementation PLAssetReader


- (instancetype)initWithURL:(NSURL *)url frameRate:(NSUInteger)frameRate stereo:(BOOL)isStereo {
    self = [super init];
    if (self) {
        _frameRate = frameRate;
        _numberOfChannels = isStereo ? 2 : 1;
        self.inputAsset = [AVAsset assetWithURL:url];
        [self setupWithStartTime:kCMTimeZero];
    }
    return self;
}

- (BOOL)hasAudio {
    AVAsset *asset = [self.assetReader asset];
    return [asset tracksWithMediaType:(AVMediaTypeAudio)].count > 0;
}

- (BOOL)hasVideo {
    AVAsset *asset = [self.assetReader asset];
    return [asset tracksWithMediaType:(AVMediaTypeVideo)].count > 0;
}

- (void)getVideoInfo:(int *)width height:(int *)height frameRate:(float *)fps duration:(CMTime *)duration {
    NSArray *videoAssetTracks = [self.inputAsset tracksWithMediaType:AVMediaTypeVideo];
    if (videoAssetTracks.count) {
        AVAssetTrack *videoTrack = [videoAssetTracks firstObject];
        *width = videoTrack.naturalSize.width;
        *height = videoTrack.naturalSize.height;
        *fps = videoTrack.nominalFrameRate;
    }
    *duration = self.inputAsset.duration;
}

- (void)seekTo:(CMTime)time frameRate:(NSUInteger)frameRate {
    if (self.assetReader) {
        [self.assetReader cancelReading];
        self.assetReader = nil;
    }
    
    _frameRate = frameRate;
    [self setupWithStartTime:time];
}

- (void)setupWithStartTime:(CMTime)startTime {
    
    if (CMTimeCompare(self.inputAsset.duration, startTime) <= 0) {
        NSLog(@"error: the start time > duration");
        return;
    }
    
    self.startTime = startTime;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = nil;
    AVMutableCompositionTrack *audioCompositionTrack = nil;
    
    NSArray *audioAssetTracks = [self.inputAsset tracksWithMediaType:AVMediaTypeAudio];
    NSArray *videoAssetTracks = [self.inputAsset tracksWithMediaType:AVMediaTypeVideo];
    if (audioAssetTracks.count) {
        audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioTrack = [audioAssetTracks firstObject];
        CMTimeRange range = CMTimeRangeMake(startTime, CMTimeSubtract(self.inputAsset.duration, startTime));
        [audioCompositionTrack insertTimeRange:range ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    if (videoAssetTracks.count) {
        videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *videoTrack = [videoAssetTracks firstObject];
        CMTimeRange range = CMTimeRangeMake(startTime, CMTimeSubtract(self.inputAsset.duration, startTime));
        [videoCompositionTrack insertTimeRange:range ofTrack:videoTrack atTime:kCMTimeZero error:nil];
        videoCompositionTrack.preferredTransform = videoTrack.preferredTransform;
    }
    
    [self startWithAsset:composition];
}

- (void)startWithAsset:(AVAsset *)asset {
    
    NSError *error = nil;
    self.assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    
    AVAssetTrack *videoTrack = nil;
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count) {
        videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        NSDictionary *readerOutputSettings = nil;
        // 超过720的视频 最大输出720p，在分屏录制中，720p的数据够高清了
        AVVideoComposition *videoComposition = [self videoCompositionWithTrack:videoTrack];
        if (MIN(videoComposition.renderSize.width, videoComposition.renderSize.height) > 720) {
            CGSize size = videoComposition.renderSize;
            if (size.width > size.height) {
                size.height = 720;
                size.width = 720 * videoComposition.renderSize.width / videoComposition.renderSize.height;
            } else {
                size.width = 720;
                size.height = 720 * videoComposition.renderSize.height / videoComposition.renderSize.width;
            }
            readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange), kCVPixelBufferPixelFormatTypeKey, @(size.width), kCVPixelBufferWidthKey, @(size.height), kCVPixelBufferHeightKey, nil];
        } else {
            readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange), kCVPixelBufferPixelFormatTypeKey, nil];
        }
        _videoReaderOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:@[videoTrack] videoSettings:readerOutputSettings];
        _videoReaderOutput.videoComposition = videoComposition;
        [_assetReader addOutput:_videoReaderOutput];
        _videoReaderOutput.supportsRandomAccess = NO;
    }
    
    AVAssetTrack *audioTrack = nil;
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count) {
        audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithInteger:self.numberOfChannels], AVNumberOfChannelsKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithInteger:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithFloat:48000], AVSampleRateKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,// why must be NO
                                       nil];
        _audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack
                                                                        outputSettings:audioSettings];
        
        [_assetReader addOutput:_audioReaderOutput];
        _audioReaderOutput.supportsRandomAccess = NO;
    }
    
    if (_assetReader.outputs.count) {
        [_assetReader startReading];
    }
}

- (CMSampleBufferRef)readAudioSampleBuffer {
    if (AVAssetReaderStatusReading != _assetReader.status) return NULL;
    CMSampleBufferRef audioSample = [_audioReaderOutput copyNextSampleBuffer];
    return audioSample;
}

- (CMSampleBufferRef)readVideoSampleBuffer {
    if (AVAssetReaderStatusReading != _assetReader.status) return NULL;
   
    CMSampleBufferRef sample = [_videoReaderOutput copyNextSampleBuffer];
    return sample;
}

- (void)dealloc {
    [_assetReader cancelReading];
    _assetReader = nil;
}

- (AVVideoComposition *)videoCompositionWithTrack:(AVAssetTrack *)videoAssetTrack {
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.asset.duration);
    
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
    instruction.layerInstructions = @[layerInstruction];
    
    CGAffineTransform transform =  [self.class verifytransform:videoAssetTrack.preferredTransform
                                                   naturalSize:videoAssetTrack.naturalSize];
    
    CGSize renderSize   = CGSizeZero;
    BOOL isPortrait     = [self.class checkForPortrait:transform];
    CGSize naturalSize  = videoAssetTrack.naturalSize;
    if (isPortrait) {
        renderSize = CGSizeMake(naturalSize.height, naturalSize.width);
    } else {
        renderSize = naturalSize;
    }
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize         = renderSize;
    videoComposition.instructions       = @[instruction];
    videoComposition.frameDuration  = CMTimeMake(1000, _frameRate*1000);
    
    return videoComposition;
}

+ (CGAffineTransform)verifytransform:(CGAffineTransform)transform naturalSize:(CGSize)naturalSize {
    
    if (1 == transform.a && 1 == transform.d) {
        transform.tx = 0;
        transform.ty = 0;
    } else if (-1 == transform.b && 1 == transform.c) {
        transform.tx = 0;
        transform.ty = naturalSize.width;
    } else if (-1 == transform.a && -1 == transform.d) {
        transform.tx = naturalSize.width;
        transform.ty = naturalSize.height;
    } else if (1 == transform.b && -1 == transform.c) {
        transform.tx = naturalSize.height;
        transform.ty = 0;
    }
    
    return transform;
}

+ (BOOL)checkForPortrait:(CGAffineTransform)transform {
    
    BOOL assetPortrait  = NO;
    
    if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        //is portrait
        assetPortrait = YES;
    }
    else if(transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        //is portrait
        assetPortrait = YES;
    }
    else if(transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
        //is landscape
    }
    else if(transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        //is landscape
    }
    
    return assetPortrait;
}

@end
