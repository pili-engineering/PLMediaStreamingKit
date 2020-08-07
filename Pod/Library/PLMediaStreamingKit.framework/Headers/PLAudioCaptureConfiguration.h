//
//  PLAudioCaptureConfiguration.h
//  PLCaptureKit
//
//  Created by WangSiyu on 5/5/16.
//  Copyright © 2016 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLAudioCaptureConfiguration : NSObject

/*!
 @abstract 采集音频数据的声道数，默认为 1
 
 @warning  并非所有采集设备都支持多声道数据的采集，可以通过检查 [AVAudioSession sharedInstance].maximumInputNumberOfChannels 得到当前采集设备支持的最大声道数
 */
@property (nonatomic, assign) NSUInteger channelsPerFrame;

/*!
 @abstract   回声消除开关，默认为 NO
 
 @discussion 普通直播用到回声消除的场景不多，当用户开启返听功能，并且使用外放时，可打开这个开关，防止产生尖锐的啸叫声。
 */
@property (nonatomic, assign) BOOL acousticEchoCancellationEnable;

/*!
 @abstract 创建一个默认配置的 PLAudioCaptureConfiguration 实例.
  
 @return   创建的默认 PLAudioCaptureConfiguration 对象
 */
+ (instancetype)defaultConfiguration;

@end
