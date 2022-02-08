//
//  PLStreamViewController.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/8.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLStreamViewController : UIViewController


@property (nonatomic,strong) PLSettings *mSettings;;
@property (nonatomic, strong) NSURL *pushURL;

// 外部导入数据的源
@property (nonatomic, strong) NSURL *mediaURL;

@end

NS_ASSUME_NONNULL_END
