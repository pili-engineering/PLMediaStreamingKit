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

/*!
 @protocol   PLAudioPlayerDelegate

 @discussion PLAudioPlayer 在运行过程中的回调。
 */
@protocol PLAudioPlayerDelegate <NSObject>

@optional

/*!
 @abstract   音频播放进度

 @discussion 可通过该回调，获取 audioDidPlayedRate 值显示当前播放进度。
 */
- (void)audioPlayer:(PLAudioPlayer *)audioPlayer audioDidPlayedRateChanged:(double)audioDidPlayedRate;

/*!
 @abstract   播放音频文件发生错误

 @discussion fileError 错误详见 PLAudioPlayerFileError
 */
- (void)audioPlayer:(PLAudioPlayer *)audioPlayer findFileError:(PLAudioPlayerFileError)fileError;

/*!
 @abstract   音频播放完成的回调

 @discussion 若要实现循环播放，则可在播放完成的回调内返回 YES 再次播放
 
 @return     是否再次从头开始播放
*/
- (BOOL)didAudioFilePlayingFinishedAndShouldAudioPlayerPlayAgain:(PLAudioPlayer *)audioPlayer;

@end

/*!
 @abstract 音频播放类。
 
 @warning  仅支持 iOS 8 及以上版本，低于此版本可能发生 crash。
 */
@interface PLAudioPlayer : NSObject

@property (nonatomic, weak) id<PLAudioPlayerDelegate> delegate;

/*!
 @abstract 间隔多久回调一次 delegate 的 audioPlayer:audioDidPlayedRateChanged: 以通知 audioDidPlayedRate 发生了变化。
 
 @see audioDidPlayedRate
 */
@property (nonatomic, assign) NSTimeInterval audioDidPlayedRateUpdateInterval;

/*!
 @abstract 音频文件地址
 */
@property (nonatomic, strong) NSString *audioFilePath;

/*!
 @abstract 是否正在播放音频文件
 */
@property (nonatomic, getter=isRunning) BOOL running;

/*!
 @abstract 音频文件的播放进度。取值 0～1，其中 0 标示还未开始播，1 标示已经播完了。
 */
@property (nonatomic) double audioDidPlayedRate;

/*!
 @abstract 音量。取值 0～1
 */
@property (nonatomic) double volume;

/*!
 @abstract 音频文件时长
 */
@property (nonatomic, readonly) NSTimeInterval audioLength;

/*!
 @abstract 播放
 */
- (void)play;

/*!
 @abstract 暂停
 */
- (void)pause;

/*!
 @abstract 停止，文件资源将会被释放
 */
- (void)stopAndRelease;

@end
