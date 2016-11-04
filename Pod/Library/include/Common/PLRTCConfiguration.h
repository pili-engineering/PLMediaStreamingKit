//
//  PLRTCConfiguration.h
//  PLMediaStreamingKit
//
//  Created by lawder on 16/8/16.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTypeDefines.h"

@interface PLRTCConfiguration : NSObject
<
NSCopying
>

/**
 @brief 设置连麦窗口的大小，默认是 PLRTCVideoSizePresetDefault，即使用传入的视频数据的 size；
 由于主播涉及到画面合成和推流，可不设置或者设置较大 size，其它连麦者可以设置较小 size。
 */
@property (nonatomic, assign) PLRTCVideoSizePreset videoSize;
@property (nonatomic, assign) PLRTCConferenceType conferenceType;

+ (instancetype)defaultConfiguration;

-(instancetype)initWithVideoSize:(PLRTCVideoSizePreset)videoSize;

-(instancetype)initWithVideoSize:(PLRTCVideoSizePreset)videoSize
                  conferenceType:(PLRTCConferenceType)conferenceType;

@end
