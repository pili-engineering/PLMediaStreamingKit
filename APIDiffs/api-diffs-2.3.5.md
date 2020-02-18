# PLMediaStreamingKit 2.3.4 to 2.3.5 API Differences

## General Headers

```
PLMediaStreamingSession.h
```   
- *Added* `- (CVPixelBufferRef __nonnull)mediaStreamingSession:(PLMediaStreamingSession *__nonnull)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer timingInfo:(CMSampleTimingInfo)timingInfo;`

- *Deprecated* `- (CVPixelBufferRef)mediaStreamingSession:(PLMediaStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer;`

- *Added* ` - (void)pushSEIMessage:(nonnull NSString *)message repeat:(NSInteger)repeatNum;`

