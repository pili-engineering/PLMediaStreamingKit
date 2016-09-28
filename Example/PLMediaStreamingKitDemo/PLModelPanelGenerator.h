//
//  PLModelPanelGenerator.h
//  PLCameraStreamingKitDemo
//
//  Created by TaoZeyu on 16/5/27.
//  Copyright © 2016年 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPanelDelegateGenerator.h"

@class PLCameraStreamingSession;

@interface PLModelPanelGenerator : NSObject

- (instancetype)initWithMediaStreamingSession:(PLMediaStreamingSession *)streamingSession panelDelegateGenerator:(PLPanelDelegateGenerator *)generator;
- (NSArray *)generate;

@end
