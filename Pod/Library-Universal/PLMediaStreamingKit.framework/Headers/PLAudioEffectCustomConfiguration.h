//
//  PLAudioEffectCustomConfiguration.h
//  PLCameraStreamingKit
//
//  Created by TaoZeyu on 16/6/21.
//  Copyright © 2016年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLAudioEffectConfiguration.h"
#import <AVFoundation/AVFoundation.h>
#import "PLTypeDefines.h"

@interface PLAudioEffectCustomConfiguration : PLAudioEffectConfiguration

/*!
 @abstract 用户自定义音效过滤器
 
 @param block PLAudioEffectCustomConfigurationBlock
 
 @return PLAudioEffectCustomConfiguration 对象
 */
+ (instancetype)configurationWithBlock:(PLAudioEffectCustomConfigurationBlock)block;

@end
