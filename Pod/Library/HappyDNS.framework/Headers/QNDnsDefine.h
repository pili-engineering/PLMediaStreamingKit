//
//  QNDnsDefine.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QNDnsOpCode) {
    QNDnsOpCodeQuery = 0,  // 标准查询
    QNDnsOpCodeIQuery = 1, // 反向查询
    QNDnsOpCodeStatus = 2, // DNS状态请求
    QNDnsOpCodeUpdate = 5, // DNS域更新请求
};
