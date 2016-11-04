# PLMediaStreamingKit 2.1.3 to 2.1.4 API Differences


```
PLAudioStreamingConfiguration.h
```
- *Added* property `@property (nonatomic, copy) NSArray   *inputAudioChannelDescriptions;`
- *Added* method `- (instancetype)initWithEncodedAudioSampleRate:(PLStreamingAudioSampleRate)sampleRate
                       encodedNumberOfChannels:(UInt32)numberOfChannels
                                  audioBitRate:(PLStreamingAudioBitRate)audioBitRate
                 inputAudioChannelDescriptions:(NSArray *)inputAudioChannelDescriptions;`

```
PLRTCConfiguration.h
```
- *Added* property `@property (nonatomic, assign) PLRTCConferenceType conferenceType;`
- *Added* method `-(instancetype)initWithVideoSize:(PLRTCVideoSizePreset)videoSize
                  conferenceType:(PLRTCConferenceType)conferenceType`
                  
```
PLTypeDefines.h
```
- *Added* enum `PLH264EncoderType`
- *Added* enum `PLAudioStreamEndian`
- *Added* enum `PLRTCConferenceType`
- *Added* const `kPLAudioChannelDefault`
- *Added* const `kPLAudioChannelApp`
- *Added* const `kPLAudioChannelMic`

```
PLVideoStreamingConfiguration.h
```
- *Added* property `@property (nonatomic, assign) PLH264EncoderType videoEncoderType;`
- *Added* method `- (instancetype)initWithVideoSize:(CGSize)videoSize
     expectedSourceVideoFrameRate:(NSUInteger)expectedSourceVideoFrameRate
         videoMaxKeyframeInterval:(NSUInteger)videoMaxKeyframeInterval
              averageVideoBitRate:(NSUInteger)averageVideoBitRate
                videoProfileLevel:(NSString *)videoProfileLevel
                 videoEncoderType:(PLH264EncoderType)videoEncoderType NS_DESIGNATED_INITIALIZER;`
- *Modified* method `- (instancetype)initWithVideoSize:(CGSize)videoSize
     expectedSourceVideoFrameRate:(NSUInteger)expectedSourceVideoFrameRate
         videoMaxKeyframeInterval:(NSUInteger)videoMaxKeyframeInterval
              averageVideoBitRate:(NSUInteger)averageVideoBitRate
                videoProfileLevel:(NSString *)videoProfileLevel DEPRECATED_ATTRIBUTE;`
                
```
PLMediaStreamingSession.h
```
- *Added* method `- (void)postDiagnosisWithCompletionHandler:(nullable PLStreamDiagnosisResultHandler)handle;`
- *Added* method `- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didJoinConferenceOfUserID:(NSString *)userID;`
- *Added* method `- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didLeaveConferenceOfUserID:(NSString *)userID;` 
- *Added* property `@property (nonatomic, strong, readonly) NSArray *rtcParticipants;`
- *Added* property `@property (nonatomic, assign, readonly) NSUInteger rtcParticipantsCount;`

```
PLStreamingSession.h
```
- *Added* type `typedef void (^PLStreamDiagnosisResultHandler)(NSString * _Nullable diagnosisResult);`
- *Added* method `- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer withChannelID:(const NSString *)channelID completion:(void (^)(BOOL success))handler;`
- *Added* method `- (void)postDiagnosisWithCompletionHandler:(nullable PLStreamDiagnosisResultHandler)handle;`