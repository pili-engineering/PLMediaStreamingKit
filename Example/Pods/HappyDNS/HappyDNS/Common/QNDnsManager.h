//
//  QNDnsManager.h
//  HappyDNS
//
//  Created by bailong on 15/6/23.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QNNetworkInfo;
@class QNDomain;

/**
 *    上传进度回调函数
 *
 *    @param key     上传时指定的存储key
 *    @param percent 进度百分比
 */
typedef NSArray * (^QNGetAddrInfoCallback)(NSString *host);

@protocol QNIpSorter <NSObject>
- (NSArray *)sort:(NSArray *)ips;
@end

@interface QNDnsManager : NSObject
- (NSArray *)query:(NSString *)domain;
- (NSArray *)queryWithDomain:(QNDomain *)domain;
- (void)onNetworkChange:(QNNetworkInfo *)netInfo;
- (instancetype)init:(NSArray *)resolvers networkInfo:(QNNetworkInfo *)netInfo;
- (instancetype)init:(NSArray *)resolvers networkInfo:(QNNetworkInfo *)netInfo sorter:(id<QNIpSorter>)sorter;
- (instancetype)putHosts:(NSString *)domain ip:(NSString *)ip;
- (instancetype)putHosts:(NSString *)domain ip:(NSString *)ip provider:(int)provider;
+ (void)setGetAddrInfoBlock:(QNGetAddrInfoCallback)block;
@end

@interface QNDnsManager (NSURL)
- (NSURL *)queryAndReplaceWithIP:(NSURL *)url;
@end