//
//  PLStreamingSessionConstructor.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/24.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import "PLMediaStreamingKit.h"

@class PLStreamingSessionConstructor;

@protocol PLStreamingSessionConstructorDelegate <NSObject>

- (void)PLStreamingSessionConstructor:(PLStreamingSessionConstructor *)constructor didGetStreamURL:(NSURL *)streamURL;

@end

@interface PLStreamingSessionConstructor : NSObject

@property (nonatomic, weak) id<PLStreamingSessionConstructorDelegate>delegate;

- (instancetype)initWithStreamCloudURL:(NSURL *)streamCloudURL;
- (PLMediaStreamingSession *)streamingSession;

@end
