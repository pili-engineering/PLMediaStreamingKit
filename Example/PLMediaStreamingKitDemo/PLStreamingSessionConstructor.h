//
//  PLStreamingSessionConstructor.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/24.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

@interface PLStreamingSessionConstructor : NSObject

- (instancetype)initWithAudioCaptureConfiguration:(PLAudioCaptureConfiguration *)audioCaptureConfiguration;
- (PLMediaStreamingSession *)streamingSession;

@end
