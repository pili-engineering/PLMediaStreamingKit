//
//  PLVideoCaptureConfiguration.h
//  PLCaptureKit
//
//  Created by WangSiyu on 5/5/16.
//  Copyright © 2016 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PLVideoCaptureConfiguration : NSObject
<
NSCopying
>

/*!
 @abstract 采集的视频数据的帧率，默认为 24
 */
@property (nonatomic, assign) NSUInteger videoFrameRate;

/*!
 @abstract 采集的视频的 sessionPreset，默认为 AVCaptureSessionPreset640x480
 */
@property (nonatomic, copy) NSString *sessionPreset;

/*!
 @abstract 前置预览是否开启镜像，默认为 YES 开启
 */
@property (nonatomic, assign) BOOL previewMirrorFrontFacing;

/*!
 @abstract 后置预览是否开启镜像，默认为 NO 关闭
 */
@property (nonatomic, assign) BOOL previewMirrorRearFacing;

/*!
 @abstract 前置摄像头，推的流是否开启镜像，默认为 NO 关闭
 */
@property (nonatomic, assign) BOOL streamMirrorFrontFacing;

/*!
 @abstract 后置摄像头，推的流是否开启镜像，默认为 NO 关闭
 */
@property (nonatomic, assign) BOOL streamMirrorRearFacing;

/*!
 @abstract 开启 camera 时的采集摄像头位置，默认为 AVCaptureDevicePositionBack
 */
@property (nonatomic, assign) AVCaptureDevicePosition position;

/*!
 @abstract 开启 camera 时的采集摄像头的旋转方向，默认为 AVCaptureVideoOrientationPortrait
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/*!
 @abstract 创建一个默认配置的 PLVideoCaptureConfiguration 实例.
 
 @return 创建的默认 PLVideoCaptureConfiguration 对象
 */
+ (instancetype)defaultConfiguration;

/*!
 @abstract 初始化方法，指定帧率、分辨率、前后预览镜像、编码镜像、摄像头位置以及摄像头方向生成配置。
 
 @param videoFrameRate           帧率
 @param sessionPreset            分辨率
 @param previewMirrorFrontFacing 前置预览镜像
 @param previewMirrorRearFacing  后置预览镜像
 @param streamMirrorFrontFacing  前置编码镜像
 @param streamMirrorRearFacing   后置编码镜像
 @param position                 摄像头位置
 @param videoOrientation         摄像头方向

 @return 创建的默认 PLVideoCaptureConfiguration 对象
*/
-(instancetype)initWithVideoFrameRate:(NSUInteger)videoFrameRate sessionPreset:(NSString *)sessionPreset previewMirrorFrontFacing:(BOOL)previewMirrorFrontFacing previewMirrorRearFacing:(BOOL)previewMirrorRearFacing streamMirrorFrontFacing:(BOOL)streamMirrorFrontFacing streamMirrorRearFacing:(BOOL)streamMirrorRearFacing cameraPosition:(AVCaptureDevicePosition)position videoOrientation:(AVCaptureVideoOrientation)videoOrientation;
@end
