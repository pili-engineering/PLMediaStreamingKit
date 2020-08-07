//
//  PLRotatePixelBufferProcessor.h
//  PLMediaStreamingKit
//
//  Created by suntongmian on 2018/8/20.
//  Copyright © 2018年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLTypeDefines.h"

// 目前支持处理 NV12, BGRA32 视频数据

@protocol PLRotatePixelBufferProcessorProtocol <NSObject>

/*!
 @abstract 需要从原始图片中裁剪出来的部分的位置和大小
 
 @since    v2.3.4
 */
@property (nonatomic, assign) CGRect sourceRect;

/*!
 @abstract 裁剪出来的部分放置在新图之中的位置和大小
 
 @since    v2.3.4
 */
@property (nonatomic, assign) CGRect destRect;

/*!
 @abstract 新图的整体画幅大小
 
 @since    v2.3.4
 */
@property (nonatomic, assign) CGSize destFrameSize;

/*!
 @abstract 当被裁剪的部分比例与在新图中需要安放的位置的比例不同时选择的填充模式
 
 @since    v2.3.4
 */
@property (nonatomic, assign) PLVideoFillModeType aspectMode;

/*!
 @abstract 旋转类型，默认值为 PLRotateModeNone
 
 @since    v2.3.4
 */
@property (nonatomic, assign) PLRotateModeType rotateMode;

/*!
 @abstract 初始化一个 PLRotatePixelBufferProcessor 对象
 
 @param sourceRect    需要从原始图片中裁剪出来的部分的位置和大小
 @param destRect      裁剪出来的部分放置在新图之中的位置和大小
 @param destFrameSize 新图的整体画幅大小
 @param aspectMode    当被裁剪的部分比例与在新图中需要安放的位置的比例不同时选择的填充模式
 
 @return 初始化后的 PLRotatePixelBufferProcessor 对象
 
 @since  v2.3.4
 */
- (instancetype)initWithSourceRect:(CGRect)sourceRect destRect:(CGRect)destRect destFrameSize:(CGSize)destFrameSize aspectMode:(PLVideoFillModeType)aspectMode;

/*!
 @abstract 用于处理图像的接口
 
 @param sourceBuffer 原始图片的对象
 
 @return 处理之后的 CVPixelBufferRef 对象
 
 @discussion 使用该接口进行图像处理需要注意的是，为了保持图像处理的效率，减小开销，该类内部会持有一个 CVPixelBufferRef 并在每次都会返回该对象，因此在每次调用之后请确认对返回的数据已经使用完毕再进行下一次调用，否则会出现非预期的问题
 
 @since      v2.3.4
 */
- (CVPixelBufferRef)processPixelBuffer:(CVPixelBufferRef)sourceBuffer;

@end

@interface PLRotatePixelBufferProcessor : NSObject <PLRotatePixelBufferProcessorProtocol>

@end

/*!
 * 视频帧的裁剪+旋转的使用示例
 
 // -----------------------------------------------------
 // step 1. 假设采集的视频帧为竖屏（srcFrameWidth < srcFrameHeight），比如 (1080, 1920)。
 // step 2. 需要设置 destRect 的 size 为竖屏 (destRect.size.width < destRect.size.height)，比如（720, 1280）。
 // step 3. 需要设置 destFrameSize 为竖屏 (destVideoSize.width < destVideoSize.height)，比如（720, 1280）。
 // step 4. 最后使用 rotateMode 的 PLRotateModeDegree90 或 PLRotateModeDegree270 来让 rotatePixelBufferProcessor 旋转视频帧，让最终输出的视频帧为横屏，比如（1280, 720）。
 
    支持根据移动设备的方向，来实时设置图像的旋转方向 self.rotatePixelBufferProcessor.rotateMode
 // -----------------------------------------------------

 // 声明属性
 @property (nonatomic, strong) PLRotatePixelBufferProcessor *rotatePixelBufferProcessor;
 
 // 持续接收视频帧
 CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
 // 旋转视频帧类的初始化
 if (!self.rotatePixelBufferProcessor) {
    size_t srcFrameWidth = CVPixelBufferGetWidth(pixelBuffer); // 比如 srcFrameWidth = 1080
    size_t srcFrameHeight = CVPixelBufferGetHeight(pixelBuffer); // 比如 srcFrameHeight = 1920
 
    CGRect sourceRect = CGRectMake(0, 0, srcFrameWidth, srcFrameHeight);
 
    CGRect destRect = CGRectMake(0, 0, 720, 1280);
    CGSize destFrameSize = CGSizeMake(720, 1280);
    PLVideoFillModeType aspectMode = PLVideoFillModePreserveAspectRatio;
 
    self.rotatePixelBufferProcessor = [[PLRotatePixelBufferProcessor alloc] initWithSourceRect:sourceRect destRect:destRect destFrameSize:destFrameSize aspectMode:aspectMode];
    self.rotatePixelBufferProcessor.rotateMode = PLRotateModeDegree90;
 }
 // 执行视频帧旋转
 pixelBuffer = [self.rotatePixelBufferProcessor processPixelBuffer:pixelBuffer]; // 比如经旋转 PLRotateModeDegree90 处理后的 pixelBuffer 的 size 为 (1280, 720)
 */
