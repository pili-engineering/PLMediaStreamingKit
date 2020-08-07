//
//  PLAudioStreamingConfiguration.h
//  PLCameraStreamingKit
//
//  Created on 15/8/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLTypeDefines.h"

/*!
 @class      PLAudioStreamingConfiguration
 @abstract   音频编码推流的相关配置
 
 @since      v1.0.0
 */
@interface PLAudioStreamingConfiguration : NSObject <NSCopying>

/*!
 @abstract 音频编码的采样率, 默认为设备采样率
 */
@property (nonatomic, assign) PLStreamingAudioSampleRate encodedAudioSampleRate;

/*!
 @abstract 音频编码比特率，默认为 96kbps
 */
@property (nonatomic, assign) PLStreamingAudioBitRate audioBitRate;

/*!
 @abstract 编码的声道数，默认为 1
 */
@property (nonatomic, assign) UInt32 encodedNumberOfChannels;

/*!
 @abstract 编码模式，默认为 PLAACEncoderType_iOS_AAC
 */
@property (nonatomic, assign) PLAACEncoderType audioEncoderType;

/*!
 @abstract 输入的音频流描述，默认为单路音频 @[kPLAudioChannelDefault]
 
 @discussion 目前提供两路音频流混音功能，对于ReplayKit录屏推流，若要实现 App Audio 与 Mic Audio 的混音，需设置该属性为 @[kPLAudioChannelApp, kPLAudioChannelMic]
 */
@property (nonatomic, copy) NSArray *inputAudioChannelDescriptions;

/*!
 @abstract 类方法，默认 kPLAudioStreamingQualityHigh2
 
 @return PLAudioStreamingConfiguration 实例对象
 */
+ (instancetype)defaultConfiguration;

/*!
 @abstract 类方法，指定可选分辨率和推流质量生成一个配置
 */
+ (instancetype)configurationWithAudioQuality:(NSString *)quality;

/*!
 @abstract 提供一个能支持的编码采样率
 
 @param sampleRate 想要的编码采样率
 
 @return PLStreamingAudioSampleRate 如果能支持 sampleRate，则原样返回 sampleRate。如果不能支持 sampleRate，返回一个比 sampleRate 大但最接近 sampleRate 的可以被支持的编码采样率。
 */
+ (PLStreamingAudioSampleRate)mostSimilarSupportedValueWithEncodedAudioSampleRate:(NSUInteger)sampleRate;

/*!
 @abstract 初始化方法，指定可选分辨率和推流质量生成一个配置

 @param quality 质量配置

 @return PLAudioStreamingConfiguration 实例对象
*/
- (instancetype)initWithAudioQuality:(NSString *)quality;

/*!
 @abstract 初始化方法，指定采样率、声道数和码率生成一个配置

 @param sampleRate       采样率
 @param numberOfChannels 声道数
 @param audioBitRate     码率

 @return PLAudioStreamingConfiguration 实例对象
*/
- (instancetype)initWithEncodedAudioSampleRate:(PLStreamingAudioSampleRate)sampleRate
                       encodedNumberOfChannels:(UInt32)numberOfChannels
                                  audioBitRate:(PLStreamingAudioBitRate)audioBitRate;

/*!
 @abstract 初始化方法，指定采样率、声道数、码率和音频声道描述信息生成一个配置

 @param sampleRate                        采样率
 @param numberOfChannels                  声道数
 @param audioBitRate                      码率
 @param inputAudioChannelDescriptions     音频声道描述信息

 @return PLAudioStreamingConfiguration 实例对象
*/
- (instancetype)initWithEncodedAudioSampleRate:(PLStreamingAudioSampleRate)sampleRate
                       encodedNumberOfChannels:(UInt32)numberOfChannels
                                  audioBitRate:(PLStreamingAudioBitRate)audioBitRate
                 inputAudioChannelDescriptions:(NSArray *)inputAudioChannelDescriptions;

/*!
 @abstract 初始化方法，指定采样率、声道数、编码类型、码率和音频声道描述信息生成一个配置

 @param sampleRate                        采样率
 @param numberOfChannels                  声道数
 @param audioBitRate                      码率
 @param inputAudioChannelDescriptions     音频声道描述信息

 @return PLAudioStreamingConfiguration 实例对象
*/
- (instancetype)initWithEncodedAudioSampleRate:(PLStreamingAudioSampleRate)sampleRate
                       encodedNumberOfChannels:(UInt32)numberOfChannels
                              audioEncoderType:(PLAACEncoderType)audioEncoderType
                                  audioBitRate:(PLStreamingAudioBitRate)audioBitRate
                 inputAudioChannelDescriptions:(NSArray *)inputAudioChannelDescriptions;

@end
