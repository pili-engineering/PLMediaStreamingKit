//
//  PLStreamViewController.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/8.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLStreamViewController : UIViewController

#warning PLMediamediaSession 音视频采集 推流核心类
@property (nonatomic, strong) PLMediaStreamingSession *mediaSession;
#warning PLStreamingSession 外部导入音视频 推流核心类
@property (nonatomic, strong) PLStreamingSession *streamSession;

// 0 音视频
// 1 纯音频
// 2 外部导入
// 3 录屏
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSURL *pushURL;

// 外部导入数据的源
@property (nonatomic, strong) NSURL *mediaURL;

@end

NS_ASSUME_NONNULL_END
