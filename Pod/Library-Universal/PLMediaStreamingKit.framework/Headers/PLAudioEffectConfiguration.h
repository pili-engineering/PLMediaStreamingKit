//
//  PLAudioEffectConfiguration.h
//  PLCameraStreamingKit
//
//  Created by TaoZeyu on 16/6/21.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTypeDefines.h"

@interface PLAudioEffectConfiguration : NSObject

/**
 @brief 音效配置类型
 */
@property (nonatomic, readonly) PLAudioEffectConfigurationType type;

@end

@interface PLAudioEffectModeConfiguration : PLAudioEffectConfiguration

/**
 @brief 预设的混响音效配置 - LowLevel
 */
+ (instancetype)reverbLowLevelModeConfiguration;
/**
 @brief 预设的混响音效配置 - MediumLevel
 */
+ (instancetype)reverbMediumLevelModeConfiguration;
/**
 @brief 预设的混响音效配置 - HeightLevel
 */
+ (instancetype)reverbHeightLevelModeConfiguration;

@end

@interface PLAudioEffectReverb2Configuration : PLAudioEffectConfiguration

@property (nonatomic, assign) double decayTimeAt0Hz;
@property (nonatomic, assign) double decayTimeAtNyquist;
@property (nonatomic, assign) double cutoffFrequency;
@property (nonatomic, assign) double dryWetMix;
@property (nonatomic, assign) double gain;
@property (nonatomic, assign) double minDelayTime;
@property (nonatomic, assign) double maxDelayTime;
@property (nonatomic, assign) double randomizeReflections;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectDynamicsProcessorConfiguration : PLAudioEffectConfiguration

@property (nonatomic, assign) double threshold;
@property (nonatomic, assign) double headRoom;
@property (nonatomic, assign) double expansionRatio;
@property (nonatomic, assign) double attackTime;
@property (nonatomic, assign) double releaseTime;
@property (nonatomic, assign) double masterGain;
@property (nonatomic, assign) double inputAmplitude;
@property (nonatomic, assign) double outputAmplitude;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectBandpassConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double centerFrequency;
@property (nonatomic) double bandwidth;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectDelayConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double wetDryMix;
@property (nonatomic) double delayTime;
@property (nonatomic) double feedback;
@property (nonatomic) double lopassCutoff;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectDistortionConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double delay;
@property (nonatomic) double decay;
@property (nonatomic) double delayMix;
@property (nonatomic) double decimation;
@property (nonatomic) double rounding;
@property (nonatomic) double decimationMix;
@property (nonatomic) double linearTerm;
@property (nonatomic) double squaredTerm;
@property (nonatomic) double cubicTerm;
@property (nonatomic) double polynomialMix;
@property (nonatomic) double ringModFreq1;
@property (nonatomic) double ringModFreq2;
@property (nonatomic) double ringModBalance;
@property (nonatomic) double ringModMix;
@property (nonatomic) double softClipGain;
@property (nonatomic) double finalMix;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectNewTimePitchConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double rate;
@property (nonatomic) double pitch;
@property (nonatomic) double overlap;
@property (nonatomic) double enablePeakLocking;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectParametricEqConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double centerFrequency;
@property (nonatomic) double qFactor;
@property (nonatomic) double gain;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectPeakLimiterConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double attackTime;
@property (nonatomic) double decayTime;
@property (nonatomic) double preGain;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectVarispeedConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double playbackRate;
@property (nonatomic) double playbackCents;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectHighPassConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double cutoffFrequency;
@property (nonatomic) double resonance;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectHighShelfConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double cutoffFrequency;
@property (nonatomic) double gain;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffecLowPassConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double cutoffFrequency;
@property (nonatomic) double resonance;

+ (instancetype)defaultConfiguration;

@end

@interface PLAudioEffectLowShelfConfiguration : PLAudioEffectConfiguration

@property (nonatomic) double cutoffFrequency;
@property (nonatomic) double gain;

+ (instancetype)defaultConfiguration;

@end
