# PLMediaStreamingKit 2.1.1 to 2.1.2 API Differences

- *Added* Header `PLAudioSession.h`
- *Added* Header `PLRTCConfiguration.h`
- *Added* Header `PLRTCStreamingKit.h`
- *Added* Header `PLRTCStreamingSession.h`
- *Added* Header `PLMediaStreamingKit.h`
- *Added* Header `PLMediaStreamingSession.h`

```
PLAudioSession.h
```
- *Added* class `PLAudioSession`

```
PLRTCConfiguration.h
```
- *Added* class `PLRTCConfiguration`

```
PLRTCStreamingSession.h
```
- *Added* class `PLRTCStreamingSession`

```
PLMediaStreamingSession.h
```
- *Added* class `PLMediaStreamingSession`

```
PLVideoStreamingConfiguration.h
```
- *Modified* `+ (instancetype)configurationWithVideoSize:(CGSize)videoSize videoQuality:(NSString *)quality;` to `+ (instancetype)configurationWithVideoQuality:(NSString *)quality;`

```
PLCameraStreamingSession.h
```
- *Deleted* `@property (nonatomic, weak) id<PLStreamingSendingBufferDelegate> bufferDelegate`
- *Added* `@property (nonatomic, assign) int   receiveTimeout;`
- *Added* `@property (nonatomic, assign) int   sendTimeout;`
- *Added* `- (void)enableAdaptiveBitrateControlWithMinVideoBitRate:(NSUInteger)minVideoBitRate;`
- *Added* `- (void)disableAdaptiveBitrateControl;`
- *Added* `@property (nonatomic, assign) PLStreamAdaptiveQualityMode adaptiveQualityMode;`
- *Added* `@property (nonatomic, copy) _Nullable ConnectionInterruptionHandler connectionInterruptionHandler;`
- *Added* `@property (nonatomic, copy) _Nullable ConnectionChangeActionCallback connectionChangeActionCallback;`
- *Added* `- (void)getScreenshotWithCompletionHandler:(nullable PLStreamScreenshotHandler)handler;`

```
PLStreamingSession.h
```
- *Added* `- (void)enableAdaptiveBitrateControlWithMinVideoBitRate:(NSUInteger)minVideoBitRate;`
- *Added* `- (void)disableAdaptiveBitrateControl;`
- *Added* `@property (nonatomic, assign) PLStreamAdaptiveQualityMode adaptiveQualityMode;`
- *Added* `@property (nonatomic, copy) _Nullable ConnectionInterruptionHandler connectionInterruptionHandler;`
- *Added* `@property (nonatomic, copy) _Nullable ConnectionChangeActionCallback connectionChangeActionCallback;`
- *Added* `- (void)getScreenshotWithCompletionHandler:(nullable PLStreamScreenshotHandler)handler;`

## General Headers
