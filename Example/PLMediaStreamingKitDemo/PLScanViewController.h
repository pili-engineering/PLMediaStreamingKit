//
//  PLScanViewController.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/7/26.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLScanViewControlerDelegate <NSObject>

- (void)scanQRResult:(NSString *)qrString;

@end

@interface PLScanViewController : UIViewController

@property (nonatomic, weak) id<PLScanViewControlerDelegate> delegate;

@end
