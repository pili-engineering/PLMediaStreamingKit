//
//  PLAudioSession.h
//  PLMediaStreamingKit
//
//  Created by WangSiyu on 8/30/16.
//  Copyright © 2016 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

typedef void (^PermissionBlock)(BOOL granted);

NS_ASSUME_NONNULL_BEGIN

/*! Proxy class for AVAudioSession that adds a locking mechanism similar to
 *  AVCaptureDevice. This is used to that interleaving configurations between
 *  WebRTC and the application layer are avoided. Only setter methods are
 *  currently proxied. Getters can be accessed directly off AVAudioSession.
 *
 *  RTCAudioSession also coordinates activation so that the audio session is
 *  activated only once. See |setActive:error:|.
 */
@interface PLAudioSession : NSObject


/*! Default constructor. Do not call init. */
+ (instancetype)sharedInstance;

/*! Convenience property to access the AVAudioSession singleton. Callers should
 *  not call setters on AVAudioSession directly, but other method invocations
 *  are fine.
 */
@property(nonatomic, readonly) AVAudioSession *session;

/*! Request exclusive access to the audio session for configuration. This call
 *  will block if the lock is held by another object.
 */
- (void)lockForConfiguration;

/*! Relinquishes exclusive access to the audio session. */
- (void)unlockForConfiguration;

/* Set the session active or inactive. Note that activating an audio session is a synchronous (blocking) operation.
 Therefore, we recommend that applications not activate their session from a thread where a long blocking operation will be problematic.
 Note that this method will throw an exception in apps linked on or after iOS 8 if the session is set inactive while it has running or
 paused I/O (e.g. audio queues, players, recorders, converters, remote I/Os, etc.).
 */
- (BOOL)setActive:(BOOL)active error:(NSError **)outError;
- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)outError NS_AVAILABLE_IOS(6_0);

// Get the list of categories available on the device.  Certain categories may be unavailable on particular devices.  For example,
// AVAudioSessionCategoryRecord will not be available on devices that have no support for audio input.
@property(readonly) NSArray<NSString *> *availableCategories NS_AVAILABLE_IOS(9_0);

/* set session category */
- (BOOL)setCategory:(NSString *)category error:(NSError **)outError;
/* set session category with options */
- (BOOL)setCategory:(NSString *)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError NS_AVAILABLE_IOS(6_0);

/* get session category. Examples: AVAudioSessionCategoryRecord, AVAudioSessionCategoryPlayAndRecord, etc. */
@property(readonly) NSString *category;

/* Returns an enum indicating whether the user has granted or denied permission to record, or has not been asked */
- (AVAudioSessionRecordPermission)recordPermission NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;

/* Checks to see if calling process has permission to record audio.  The 'response' block will be called
 immediately if permission has already been granted or denied.  Otherwise, it presents a dialog to notify
 the user and allow them to choose, and calls the block once the UI has been dismissed.  'granted'
 indicates whether permission has been granted.
 */

- (void)requestRecordPermission:(PermissionBlock)response NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;

/* get the current set of AVAudioSessionCategoryOptions */
@property(readonly) AVAudioSessionCategoryOptions categoryOptions NS_AVAILABLE_IOS(6_0);

// Modes modify the audio category in order to introduce behavior that is tailored to the specific
// use of audio within an application. Examples:  AVAudioSessionModeVideoRecording, AVAudioSessionModeVoiceChat,
// AVAudioSessionModeMeasurement, etc.

// Get the list of modes available on the device.  Certain modes may be unavailable on particular devices.  For example,
// AVAudioSessionModeVideoRecording will not be available on devices that have no support for recording video.
@property(readonly) NSArray<NSString *> *availableModes NS_AVAILABLE_IOS(9_0);

- (BOOL)setMode:(NSString *)mode error:(NSError **)outError NS_AVAILABLE_IOS(5_0); /* set session mode */
@property(readonly) NSString *mode NS_AVAILABLE_IOS(5_0); /* get session mode */

- (BOOL)overrideOutputAudioPort:(AVAudioSessionPortOverride)portOverride  error:(NSError **)outError NS_AVAILABLE_IOS(6_0);

/* Will be true when another application is playing audio.
 Note: As of iOS 8.0, Apple recommends that most applications use secondaryAudioShouldBeSilencedHint instead of this property.
 The otherAudioPlaying property will be true if any other audio (including audio from an app using AVAudioSessionCategoryAmbient)
 is playing, whereas the secondaryAudioShouldBeSilencedHint property is more restrictive in its consideration of whether
 primary audio from another application is playing.
 */
@property(readonly, getter=isOtherAudioPlaying) BOOL otherAudioPlaying  NS_AVAILABLE_IOS(6_0);

/* Will be true when another application with a non-mixable audio session is playing audio.  Applications may use
 this property as a hint to silence audio that is secondary to the functionality of the application. For example, a game app
 using AVAudioSessionCategoryAmbient may use this property to decide to mute its soundtrack while leaving its sound effects unmuted.
 Note: This property is closely related to AVAudioSessionSilenceSecondaryAudioHintNotification.
 */
@property(readonly) BOOL secondaryAudioShouldBeSilencedHint  NS_AVAILABLE_IOS(8_0);

/* A description of the current route, consisting of zero or more input ports and zero or more output ports */
@property(readonly) AVAudioSessionRouteDescription *currentRoute NS_AVAILABLE_IOS(6_0);


/* Select a preferred input port for audio routing. If the input port is already part of the current audio route, this will have no effect.
 Otherwise, selecting an input port for routing will initiate a route change to use the preferred input port, provided that the application's
 session controls audio routing. Setting a nil value will clear the preference. */
- (BOOL)setPreferredInput:(nullable AVAudioSessionPortDescription *)inPort error:(NSError **)outError NS_AVAILABLE_IOS(7_0);
@property(readonly, nullable) AVAudioSessionPortDescription * preferredInput NS_AVAILABLE_IOS(7_0); /* Get the preferred input port.  Will be nil if no preference has been set */

/* Get the set of input ports that are available for routing. Note that this property only applies to the session's current category and mode.
 For example, if the session's current category is AVAudioSessionCategoryPlayback, there will be no available inputs.  */
@property(readonly, nullable) NSArray<AVAudioSessionPortDescription *> * availableInputs NS_AVAILABLE_IOS(7_0);

@end


/* AVAudioSessionHardwareConfiguration manages the set of properties that reflect the current state of
 audio hardware in the current route.  Applications whose functionality depends on these properties should
 reevaluate them any time the route changes. */
@interface PLAudioSession (AVAudioSessionHardwareConfiguration)

/* Get and set preferred values for hardware properties.  Note: that there are corresponding read-only
 properties that describe the actual values for sample rate, I/O buffer duration, etc. */

/* The preferred hardware sample rate for the session. The actual sample rate may be different. */
- (BOOL)setPreferredSampleRate:(double)sampleRate  error:(NSError **)outError NS_AVAILABLE_IOS(6_0);
@property(readonly) double preferredSampleRate NS_AVAILABLE_IOS(6_0);

/* The preferred hardware IO buffer duration in seconds. The actual IO buffer duration may be different.  */
- (BOOL)setPreferredIOBufferDuration:(NSTimeInterval)duration error:(NSError **)outError;
@property(readonly) NSTimeInterval preferredIOBufferDuration;

/* Sets the number of input channels that the app would prefer for the current route */
- (BOOL)setPreferredInputNumberOfChannels:(NSInteger)count error:(NSError **)outError NS_AVAILABLE_IOS(7_0);
@property(readonly) NSInteger preferredInputNumberOfChannels NS_AVAILABLE_IOS(7_0);

/* Sets the number of output channels that the app would prefer for the current route */
- (BOOL)setPreferredOutputNumberOfChannels:(NSInteger)count error:(NSError **)outError NS_AVAILABLE_IOS(7_0);
@property(readonly) NSInteger preferredOutputNumberOfChannels NS_AVAILABLE_IOS(7_0);


/* Returns the largest number of audio input channels available for the current route */
@property (readonly) NSInteger	maximumInputNumberOfChannels NS_AVAILABLE_IOS(7_0);

/* Returns the largest number of audio output channels available for the current route */
@property (readonly) NSInteger	maximumOutputNumberOfChannels NS_AVAILABLE_IOS(7_0);

/* A value defined over the range [0.0, 1.0], with 0.0 corresponding to the lowest analog
 gain setting and 1.0 corresponding to the highest analog gain setting.  Attempting to set values
 outside of the defined range will result in the value being "clamped" to a valid input.  This is
 a global input gain setting that applies to the current input source for the entire system.
 When no applications are using the input gain control, the system will restore the default input
 gain setting for the input source.  Note that some audio accessories, such as USB devices, may
 not have a default value.  This property is only valid if inputGainSettable
 is true.  Note: inputGain is key-value observable */
- (BOOL)setInputGain:(float)gain  error:(NSError **)outError NS_AVAILABLE_IOS(6_0);
@property(readonly) float inputGain NS_AVAILABLE_IOS(6_0); /* value in range [0.0, 1.0] */

/* True when audio input gain is available.  Some input ports may not provide the ability to set the
 input gain, so check this value before attempting to set input gain. */
@property(readonly, getter=isInputGainSettable) BOOL inputGainSettable  NS_AVAILABLE_IOS(6_0);

/* True if input hardware is available. */
@property(readonly, getter=isInputAvailable) BOOL inputAvailable  NS_AVAILABLE_IOS(6_0);

/* DataSource methods are for use with routes that support input or output data source selection.
 If the attached accessory supports data source selection, the data source properties/methods provide for discovery and
 selection of input and/or output data sources. Note that the properties and methods for data source selection below are
 equivalent to the properties and methods on AVAudioSessionPortDescription. The methods below only apply to the currently
 routed ports. */

/* Key-value observable. */
@property(readonly, nullable) NSArray<AVAudioSessionDataSourceDescription *> * inputDataSources NS_AVAILABLE_IOS(6_0);

/* Get and set the currently selected data source.  Will be nil if no data sources are available.
 Setting a nil value will clear the data source preference. */
@property(readonly, nullable) AVAudioSessionDataSourceDescription *inputDataSource NS_AVAILABLE_IOS(6_0);
- (BOOL)setInputDataSource:(nullable AVAudioSessionDataSourceDescription *)dataSource error:(NSError **)outError NS_AVAILABLE_IOS(6_0);

/* Key-value observable. */
@property(readonly, nullable) NSArray<AVAudioSessionDataSourceDescription *> * outputDataSources NS_AVAILABLE_IOS(6_0);

/* Get and set currently selected data source.  Will be nil if no data sources are available.
 Setting a nil value will clear the data source preference. */
@property(readonly, nullable) AVAudioSessionDataSourceDescription *outputDataSource NS_AVAILABLE_IOS(6_0);
- (BOOL)setOutputDataSource:(nullable AVAudioSessionDataSourceDescription *)dataSource error:(NSError **)outError NS_AVAILABLE_IOS(6_0);


/* Current values for hardware properties.  Note that most of these properties have corresponding methods
 for getting and setting preferred values.  Input- and output-specific properties will generate an error if they are
 queried if the audio session category does not support them.  Each of these will return 0 (or 0.0) if there is an error.  */

/* The current hardware sample rate */
@property(readonly) double sampleRate NS_AVAILABLE_IOS(6_0);

/* The current number of hardware input channels. Is key-value observable */
@property(readonly) NSInteger inputNumberOfChannels NS_AVAILABLE_IOS(6_0);

/* The current number of hardware output channels. Is key-value observable */
@property(readonly) NSInteger outputNumberOfChannels NS_AVAILABLE_IOS(6_0);

/* The current output volume. Is key-value observable */
@property(readonly) float outputVolume  NS_AVAILABLE_IOS(6_0); /* value in range [0.0, 1.0] */

/* The current hardware input latency in seconds. */
@property(readonly) NSTimeInterval inputLatency  NS_AVAILABLE_IOS(6_0);

/* The current hardware output latency in seconds. */
@property(readonly) NSTimeInterval outputLatency  NS_AVAILABLE_IOS(6_0);

/* The current hardware IO buffer duration in seconds. */
@property(readonly) NSTimeInterval IOBufferDuration  NS_AVAILABLE_IOS(6_0);

@end

NS_ASSUME_NONNULL_END

