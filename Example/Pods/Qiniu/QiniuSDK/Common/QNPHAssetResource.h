//
//  QNPHAssetResource.h
//  QiniuSDK
//
//  Created by   何舒 on 16/2/14.
//  Copyright © 2016年 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QNFileDelegate.h"

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90100)

@class PHAssetResource;

@interface QNPHAssetResource : NSObject <QNFileDelegate>

/**
 *    打开指定文件
 *
 *    @param path      PHLivePhoto的PHAssetResource文件
 *    @param error     输出的错误信息
 *
 *    @return 实例
 */
- (instancetype)init:(PHAssetResource *)phAssetResource
               error:(NSError *__autoreleasing *)error;

@end
#endif
