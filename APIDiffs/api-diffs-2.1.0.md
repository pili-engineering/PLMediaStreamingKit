# PLMediaStreamingKit 2.0.0 to 2.1.0 API Differences

- *Added* Header `PLCommon.h`
- *Added* Header `PLAudioEffectConfiguration.h`
- *Added* Header `PLAudioEffectCustomConfiguration.h`
- *Added* Header `PLAudioPlayer.h`

```
PLAudioEffectConfiguration.h
```

- *Added* class `PLAudioEffectConfiguration`
  - *Added* property `@property (nonatomic, readonly) PLAudioEffectConfigurationType type;`
- *Added* class `PLAudioEffectModeConfiguration`
  - *Added* method `+ (instancetype)reverbLowLevelModeConfiguration;`
  - *Added* method `+ (instancetype)reverbMediumLevelModeConfiguration;`
  - *Added* method `+ (instancetype)reverbHeightLevelModeConfiguration;`
- *Added* class `PLAudioEffectReverb2Configuration`
  - *Added* property `@property (nonatomic, assign) double decayTimeAt0Hz;`
  - *Added* property `@property (nonatomic, assign) double decayTimeAtNyquist;`
  - *Added* property `@property (nonatomic, assign) double cutoffFrequency;`
  - *Added* property `@property (nonatomic, assign) double dryWetMix;`
  - *Added* property `@property (nonatomic, assign) double gain;`
  - *Added* property `@property (nonatomic, assign) double minDelayTime;`
  - *Added* property `@property (nonatomic, assign) double maxDelayTime;`
  - *Added* property `@property (nonatomic, assign) double randomizeReflections;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectDynamicsProcessorConfiguration`
  - *Added* property `@property (nonatomic, assign) double threshold;`
  - *Added* property `@property (nonatomic, assign) double headRoom;`
  - *Added* property `@property (nonatomic, assign) double expansionRatio;`
  - *Added* property `@property (nonatomic, assign) double attackTime;`
  - *Added* property `@property (nonatomic, assign) double releaseTime;`
  - *Added* property `@property (nonatomic, assign) double masterGain;`
  - *Added* property `@property (nonatomic, assign) double inputAmplitude;`
  - *Added* property `@property (nonatomic, assign) double outputAmplitude;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectBandpassConfiguration`
  - *Added* property `@property (nonatomic, assign) double centerFrequency;`
  - *Added* property `@property (nonatomic, assign) double bandwidth;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectDelayConfiguration`
  - *Added* property `@property (nonatomic, assign) double wetDryMix;`
  - *Added* property `@property (nonatomic, assign) double delayTime;`
  - *Added* property `@property (nonatomic, assign) double feedback;`
  - *Added* property `@property (nonatomic, assign) double lopassCutoff;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectDistortionConfiguration`
  - *Added* property `@property (nonatomic, assign) double delay;`
  - *Added* property `@property (nonatomic, assign) double decay;`
  - *Added* property `@property (nonatomic, assign) double delayMix;`
  - *Added* property `@property (nonatomic, assign) double decimation;`
  - *Added* property `@property (nonatomic, assign) double rounding;`
  - *Added* property `@property (nonatomic, assign) double decimationMix;`
  - *Added* property `@property (nonatomic, assign) double linearTerm;`
  - *Added* property `@property (nonatomic, assign) double squaredTerm;`
  - *Added* property `@property (nonatomic, assign) double cubicTerm;`
  - *Added* property `@property (nonatomic, assign) double polynomialMix;`
  - *Added* property `@property (nonatomic, assign) double ringModFreq1;`
  - *Added* property `@property (nonatomic, assign) double ringModFreq2;`
  - *Added* property `@property (nonatomic, assign) double ringModBalance;`
  - *Added* property `@property (nonatomic, assign) double ringModMix;`
  - *Added* property `@property (nonatomic, assign) double softClipGain;`
  - *Added* property `@property (nonatomic, assign) double finalMix;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectNewTimePitchConfiguration`
  - *Added* property `@property (nonatomic, assign) double rate;`
  - *Added* property `@property (nonatomic, assign) double pitch;`
  - *Added* property `@property (nonatomic, assign) double overlap;`
  - *Added* property `@property (nonatomic, assign) double enablePeakLocking;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectParametricEqConfiguration`
  - *Added* property `@property (nonatomic, assign) double centerFrequency;`
  - *Added* property `@property (nonatomic, assign) double qFactor;`
  - *Added* property `@property (nonatomic, assign) double gain;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectPeakLimiterConfiguration`
  - *Added* property `@property (nonatomic, assign) double attackTime;`
  - *Added* property `@property (nonatomic, assign) double decayTime;`
  - *Added* property `@property (nonatomic, assign) double preGain;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectVarispeedConfiguration`
  - *Added* property `@property (nonatomic, assign) double playbackRate;`
  - *Added* property `@property (nonatomic, assign) double playbackCents;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectHighPassConfiguration`
  - *Added* property `@property (nonatomic, assign) double cutoffFrequency;`
  - *Added* property `@property (nonatomic, assign) double resonance;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectHighShelfConfiguration`
  - *Added* property `@property (nonatomic, assign) double cutoffFrequency;`
  - *Added* property `@property (nonatomic, assign) double gain;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffecLowPassConfiguration`
  - *Added* property `@property (nonatomic, assign) double cutoffFrequency;`
  - *Added* property `@property (nonatomic, assign) double resonance;`
  - *Added* method `+ (instancetype)defaultConfiguration;`
- *Added* class `PLAudioEffectLowShelfConfiguration`
  - *Added* property `@property (nonatomic, assign) double cutoffFrequency;`
  - *Added* property `@property (nonatomic, assign) double gain;`
  - *Added* method `+ (instancetype)defaultConfiguration;`

```
PLAudioEffectCustomConfiguration.h
```

- *Added* class `PLAudioEffectCustomConfiguration`
  - *Added* method `+ (instancetype)configurationWithBlock:(PLAudioEffectCustomConfigurationBlock)block;`

- *Added* protocol `PLAudioPlayerDelegate`
  - *Added* method `- (void)audioPlayer:(PLAudioPlayer *)audioPlayer audioDidPlayedRateChanged:(double)audioDidPlayedRate;`
  - *Added* method `- (void)audioPlayer:(PLAudioPlayer *)audioPlayer findFileError:(PLAudioPlayerFileError)fileError;`
  - *Added* method `- (BOOL)didAudioFilePlayingFinishedAndShouldAudioPlayerPlayAgain:(PLAudioPlayer *)audioPlayer;`

- *Added* class `PLAudioPlayer`
  - *Added* property `@property (nonatomic, weak) id<PLAudioPlayerDelegate> delegate;`
  - *Added* property `@property (nonatomic, assign) NSTimeInterval audioDidPlayedRateUpdateInterval;`
  - *Added* property `@property (nonatomic, strong) NSString *audioFilePath;`
  - *Added* property `@property (nonatomic, getter=isRunning) BOOL running;`
  - *Added* property `@property (nonatomic) double audioDidPlayedRate;`
  - *Added* property `@property (nonatomic) double volume;`
  - *Added* property `@property (nonatomic, readonly) NSTimeInterval audioLength;`
  - *Added* property `- (void)play;`
  - *Added* property `- (void)pause;`
  - *Added* property `- (void)stopAndRelease;`

## General Headers
