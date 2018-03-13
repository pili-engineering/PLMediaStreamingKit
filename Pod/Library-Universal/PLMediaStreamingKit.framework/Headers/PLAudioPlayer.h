//
//  PLAudioPlayer.h
//  PLCameraStreamingKit
//
//  Created by TaoZeyu on 16/6/22.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTypeDefines.h"

@class PLAudioPlayer;

@protocol PLAudioPlayerDelegate <NSObject>

@optional

- (void)audioPlayer:(PLAudioPlayer *)audioPlayer audioDidPlayedRateChanged:(double)audioDidPlayedRate;
- (void)audioPlayer:(PLAudioPlayer *)audioPlayer findFileError:(PLAudioPlayerFileError)fileError;
- (BOOL)didAudioFilePlayingFinishedAndShouldAudioPlayerPlayAgain:(PLAudioPlayer *)audioPlayer;

@end

@interface PLAudioPlayer : NSObject

@property (nonatomic, weak) id<PLAudioPlayerDelegate> delegate;

/*!
 * @brief 间隔多久回调一次 delegate 的 audioPlayer:audioDidPlayedRateChanged: 以通知 audioDidPlayedRate 发生了变化。
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 * @see audioDidPlayedRate
 */
@property (nonatomic, assign) NSTimeInterval audioDidPlayedRateUpdateInterval;

/*!
 * @brief 音频文件地址
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
@property (nonatomic, strong) NSString *audioFilePath;

/*!
 * @brief 是否正在播放音频文件
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
@property (nonatomic, getter=isRunning) BOOL running;

/*!
 * @brief 音频文件的播放进度。取值 0～1，其中 0 标示还未开始播，1 标示已经播完了。
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
@property (nonatomic) double audioDidPlayedRate;

/*!
 * @brief 音量。取值 0～1
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
@property (nonatomic) double volume;

/*!
 * @brief 音频文件时长
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
@property (nonatomic, readonly) NSTimeInterval audioLength;

/*!
 * @brief 播放
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
- (void)play;

/*!
 * @brief 暂停
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
- (void)pause;

/*!
 * @brief 停止，文件资源将会被释放
 * @discussion ［注意］该功能仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
- (void)stopAndRelease;

@end
