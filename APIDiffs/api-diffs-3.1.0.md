# PLMediaStreamingKit 3.0.8 to 3.1.0 API Differences

```
PLVideoStreamingConfiguration.h
```
- *Added* method `@property (nonatomic, assign) PLVideoCodecType videoCodecType;`

- *Added* method `- (instancetype)initWithVideoSize:(CGSize)videoSize
     expectedSourceVideoFrameRate:(NSUInteger)expectedSourceVideoFrameRate
         videoMaxKeyframeInterval:(NSUInteger)videoMaxKeyframeInterval
              averageVideoBitRate:(NSUInteger)averageVideoBitRate
                 videoCodecType:(PLVideoCodecType)videoCodecType;`

```
PLStreamingSession.h
```
- *Added* method `- (void)streamingSession:(PLStreamingSession *)session videoCodecDidChange:(PLVideoCodecType)codecType;`

## General Headers



