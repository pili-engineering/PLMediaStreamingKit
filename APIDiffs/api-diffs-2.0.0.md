# PLMediaStreamingKit 1.8.1 to 2.0.0 API Differences

```
PLCameraStreamingSession.h
```
- *Added* method `- (AudioBuffer *)cameraStreamingSession:(PLCameraStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer;`
- *Added* method `- (void)startWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;`
- *Added* method `- (void)startWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;`
- *Added* method `- (void)restartWithFeedback:(void (^)(PLStreamStartStateFeedback feedback))handler;`
- *Added* method `- (void)restartWithPushURL:(NSURL *)pushURL feedback:(void (^)(PLStreamStartStateFeedback feedback))handler;`
- *Deprecated* method `- (void)startWithCompleted:(void (^)(BOOL success))handler`
- *Deprecated* method `- (void)restartWithCompleted:(void (^)(BOOL success))handler`

## General Headers
