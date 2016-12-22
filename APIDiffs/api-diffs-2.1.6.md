# PLMediaStreamingKit 2.1.5 to 2.1.6 API Differences

```
PLMediaStreamingSession.h
```
- *Added* method `- (instancetype)initWithVideoCaptureConfiguration:(PLVideoCaptureConfiguration *)videoCaptureConfiguration
                        audioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration
                      videoStreamingConfiguration:(PLVideoStreamingConfiguration *)videoStreamingConfiguration
                      audioStreamingConfiguration:(PLAudioStreamingConfiguration *)audioStreamingConfiguration
                                           stream:(PLStream *)stream
                                              dns:(QNDnsManager *)dns;`

```
PLCameraStreamingSession.h
```
- *Deprecated* class `PLCameraStreamingSession`