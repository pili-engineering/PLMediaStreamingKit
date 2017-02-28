# PLMediaStreamingKit 2.1.6 to 2.2.0 API Differences


```
PLTypeDefines.h
```
- *Added* enum `PLAACEncoderType`


```
PLAudioCaptureConfiguration.h
```
- *Added* property `@property (nonatomic, assign) BOOL acousticEchoCancellationEnable;`
                

```
PLAudioStreamingConfiguration.h
```
- *Added* property `@property (nonatomic, assign) PLAACEncoderType audioEncoderType;`
- *Added* method `- (instancetype)initWithEncodedAudioSampleRate:(PLStreamingAudioSampleRate)sampleRate
                       encodedNumberOfChannels:(UInt32)numberOfChannels
                              audioEncoderType:(PLAACEncoderType)audioEncoderType
                                  audioBitRate:(PLStreamingAudioBitRate)audioBitRate
                 inputAudioChannelDescriptions:(NSArray *)inputAudioChannelDescriptions;`
