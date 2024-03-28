//
//  Doh.h
//  Doh
//
//  Created by yangsen on 2021/7/15.
//

#import "QNDnsResolver.h"
#import "QNDnsDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDohResolver : QNDnsResolver

/// 构造函数
/// @param server 指定 dns server  url。 eg:https://dns.google/dns-query
+ (instancetype)resolverWithServer:(NSString *)server;

/// 构造函数
/// @param server 指定 dns server url。 eg:https://dns.google/dns-query
/// @param recordType 记录类型 eg：kQNTypeA
/// @param timeout 超时时间
+ (instancetype)resolverWithServer:(NSString *)server
                        recordType:(int)recordType
                           timeout:(int)timeout;

/// 构造函数
/// @param servers 指定多个 dns server url，同时进行 dns 解析，当第一个有效数据返回时结束，或均为解析到数据时结束
///                  eg:https://dns.google/dns-query
/// @param recordType 记录类型 eg：kQNTypeA
/// @param timeout 超时时间
+ (instancetype)resolverWithServers:(NSArray <NSString *> *)servers
                         recordType:(int)recordType
                            timeout:(int)timeout;

@end

NS_ASSUME_NONNULL_END
