# PLMediaStreamingKit 3.0.2 to 3.0.3 API Differences

## General Headers


```
PLStreamingEnv.h
```   
- *Added* `+(void)initEnvWithUserUID:(NSString *)UID;`

- *Deprecated* `+(void)initEnv`


```
PLMediaStreamingSession.h
```   
- *Added* `- (AudioBuffer *)mediaStreamingSession:(PLMediaStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer asbd:(const AudioStreamBasicDescription *)asbd;`

- *Added* `- (void)reloadAudioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration;`


```
PLStreamStatus.h
```
- *Added* `@property (nonatomic, assign, readonly) double  videoBitrate;`
- *Added* `@property (nonatomic, assign, readonly) double  audioBitrate;`