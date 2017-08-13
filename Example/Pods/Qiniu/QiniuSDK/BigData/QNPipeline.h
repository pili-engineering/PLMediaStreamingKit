//
//  QNPipeline.h
//  QiniuSDK
//
//  Created by BaiLong on 2017/7/25.
//  Copyright © 2017年 Qiniu. All rights reserved.
//

#ifndef QNPipeline_h
#define QNPipeline_h

@class QNResponseInfo;

@interface QNPipelineConfig : NSObject

/**
 * 上报打点域名
 */
@property (copy, nonatomic, readonly) NSString *host;

/**
 *    超时时间 单位 秒
 */
@property (assign) UInt32 timeoutInterval;

- (instancetype)initWithHost:(NSString *)host;

- (instancetype)init;

@end

/**
 *    上传完成后的回调函数
 *
 *    @param info 上下文信息，包括状态码，错误值
 *    @param key  上传时指定的key，原样返回
 *    @param resp 上传成功会返回文件信息，失败为nil; 可以通过此值是否为nil 判断上传结果
 */
typedef void (^QNPipelineCompletionHandler)(QNResponseInfo *info);

@interface QNPipeline : NSObject

- (instancetype)init:(QNPipelineConfig *)config;

- (void)pumpRepo:(NSString *)repo
           event:(NSDictionary *)data
           token:(NSString *)token
         handler:(QNPipelineCompletionHandler)handler;

- (void)pumpRepo:(NSString *)repo
          events:(NSArray<NSDictionary *> *)data
           token:(NSString *)token
         handler:(QNPipelineCompletionHandler)handler;

@end

#endif /* QNPipeline_h */
