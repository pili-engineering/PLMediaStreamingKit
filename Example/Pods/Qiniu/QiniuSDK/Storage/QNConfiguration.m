//
//  QNConfiguration.m
//  QiniuSDK
//
//  Created by bailong on 15/5/21.
//  Copyright (c) 2015年 Qiniu. All rights reserved.
//

#import "QNConfiguration.h"
#import "HappyDNS.h"
#import "QNNetworkInfo.h"
#import "QNResponseInfo.h"
#import "QNSessionManager.h"
#import "QNSystem.h"
#import "QNUpToken.h"

const UInt32 kQNBlockSize = 4 * 1024 * 1024;

static void addServiceToDns(QNServiceAddress *address, QNDnsManager *dns) {
    NSArray *ips = address.ips;
    if (ips == nil) {
        return;
    }
    NSURL *u = [[NSURL alloc] initWithString:address.address];
    NSString *host = u.host;
    for (int i = 0; i < ips.count; i++) {
        [dns putHosts:host ip:ips[i]];
    }
}

static void addZoneToDns(QNZone *zone, QNDnsManager *dns) {
    addServiceToDns([zone up:nil], dns);
    addServiceToDns([zone upBackup:nil], dns);
}

static QNDnsManager *initDns(QNConfigurationBuilder *builder) {
    QNDnsManager *d = builder.dns;
    if (d == nil) {
        id<QNResolverDelegate> r1 = [QNResolver systemResolver];
        id<QNResolverDelegate> r2 = [[QNResolver alloc] initWithAddress:@"119.29.29.29"];
        id<QNResolverDelegate> r3 = [[QNResolver alloc] initWithAddress:@"114.114.115.115"];
        d = [[QNDnsManager alloc] init:[NSArray arrayWithObjects:r1, r2, r3, nil] networkInfo:[QNNetworkInfo normal]];
    }
    return d;
}

@implementation QNConfiguration

+ (instancetype)build:(QNConfigurationBuilderBlock)block {
    QNConfigurationBuilder *builder = [[QNConfigurationBuilder alloc] init];
    block(builder);
    return [[QNConfiguration alloc] initWithBuilder:builder];
}

- (instancetype)initWithBuilder:(QNConfigurationBuilder *)builder {
    if (self = [super init]) {

        _chunkSize = builder.chunkSize;
        _putThreshold = builder.putThreshold;
        _retryMax = builder.retryMax;
        _timeoutInterval = builder.timeoutInterval;

        _recorder = builder.recorder;
        _recorderKeyGen = builder.recorderKeyGen;

        _proxy = builder.proxy;

        _converter = builder.converter;

        _disableATS = builder.disableATS;
        if (_disableATS) {
            _dns = initDns(builder);
            [QNZone addIpToDns:_dns];
        } else {
            _dns = nil;
        }
        _zone = builder.zone;
    }
    return self;
}

@end

@implementation QNConfigurationBuilder

- (instancetype)init {
    if (self = [super init]) {
        _zone = [QNZone zone0];
        _chunkSize = 256 * 1024;
        _putThreshold = 512 * 1024;
        _retryMax = 2;
        _timeoutInterval = 60;

        _recorder = nil;
        _recorderKeyGen = nil;

        _proxy = nil;
        _converter = nil;

        if (hasAts() && !allowsArbitraryLoads()) {
            _disableATS = NO;
        } else {
            _disableATS = YES;
        }
    }
    return self;
}

@end

@implementation QNServiceAddress : NSObject

- (instancetype)init:(NSString *)address ips:(NSArray *)ips {
    if (self = [super init]) {
        _address = address;
        _ips = ips;
    }
    return self;
}

@end

@implementation QNFixedZone {
    QNServiceAddress *up;
    QNServiceAddress *upBackup;
}

/**
 *    备用上传服务器地址
 */
- (QNServiceAddress *)upBackup:(NSString *)token {
    return upBackup;
}

- (QNServiceAddress *)up:(NSString *)token {
    return up;
}

- (instancetype)initWithUp:(QNServiceAddress *)up1
                  upBackup:(QNServiceAddress *)upBackup1 {
    if (self = [super init]) {
        up = up1;
        upBackup = upBackup1;
    }

    return self;
}
@end

@interface QNAutoZoneInfo : NSObject
@property (readonly, nonatomic) NSString *upHost;
@property (readonly, nonatomic) NSString *upIp;
@property (readonly, nonatomic) NSString *upBackup;
@property (readonly, nonatomic) NSString *upHttps;

- (instancetype)init:(NSString *)uphost
                upIp:(NSString *)upip
            upBackup:(NSString *)upbackup
             upHttps:(NSString *)uphttps;
@end

@implementation QNAutoZoneInfo

- (instancetype)init:(NSString *)uphost
                upIp:(NSString *)upip
            upBackup:(NSString *)upbackup
             upHttps:(NSString *)uphttps {
    if (self = [super init]) {
        _upHost = uphost;
        _upIp = upip;
        _upBackup = upbackup;
        _upHttps = uphttps;
    }
    return self;
}

@end

@implementation QNAutoZone {
    NSString *server;
    BOOL https;
    NSMutableDictionary *cache;
    NSLock *lock;
    QNSessionManager *sesionManager;
    QNDnsManager *dns;
}

- (instancetype)initWithHttps:(BOOL)flag
                          dns:(QNDnsManager *)dns1 {
    if (self = [super init]) {
        dns = dns1;
        server = @"https://uc.qbox.me";
        https = flag;
        cache = [NSMutableDictionary new];
        lock = [NSLock new];
        sesionManager = [[QNSessionManager alloc] initWithProxy:nil timeout:10 urlConverter:nil dns:dns];
    }
    return self;
}

- (QNServiceAddress *)upBackup:(QNUpToken *)token {
    NSString *index = [token index];
    [lock lock];
    QNAutoZoneInfo *info = [cache objectForKey:index];
    [lock unlock];
    if (info == nil) {
        return nil;
    }
    if (https) {
        return [[QNServiceAddress alloc] init:info.upHttps ips:@[ info.upIp ]];
    }
    return [[QNServiceAddress alloc] init:info.upBackup ips:@[ info.upIp ]];
}

- (QNServiceAddress *)up:(QNUpToken *)token {
    NSString *index = [token index];
    [lock lock];
    QNAutoZoneInfo *info = [cache objectForKey:index];
    [lock unlock];
    if (info == nil) {
        return nil;
    }
    if (https) {
        return [[QNServiceAddress alloc] init:info.upHttps ips:@[ info.upIp ]];
    }
    return [[QNServiceAddress alloc] init:info.upHost ips:@[ info.upIp ]];
}

- (QNAutoZoneInfo *)buildInfoFromJson:(NSDictionary *)resp {
    NSDictionary *http = [resp objectForKey:@"http"];
    NSArray *up = [http objectForKey:@"up"];
    NSString *upHost = [up objectAtIndex:1];
    NSString *upBackup = [up objectAtIndex:0];
    NSString *ipTemp = [up objectAtIndex:2];
    NSArray *a1 = [ipTemp componentsSeparatedByString:@" "];
    NSString *ip1 = [a1 objectAtIndex:2];
    NSArray *a2 = [ip1 componentsSeparatedByString:@"//"];
    NSString *upIp = [a2 objectAtIndex:1];
    NSDictionary *https_ = [resp objectForKey:@"https"];
    NSArray *a3 = [https_ objectForKey:@"up"];
    NSString *upHttps = [a3 objectAtIndex:0];
    return [[QNAutoZoneInfo alloc] init:upHost upIp:upIp upBackup:upBackup upHttps:upHttps];
}

- (void)preQuery:(QNUpToken *)token
              on:(QNPrequeryReturn)ret {
    if (token == nil) {
        ret(-1);
    }
    [lock lock];
    QNAutoZoneInfo *info = [cache objectForKey:[token index]];
    [lock unlock];
    if (info != nil) {
        ret(0);
        return;
    }

    NSString *url = [NSString stringWithFormat:@"%@/v1/query?ak=%@&bucket=%@", server, token.access, token.bucket];
    [sesionManager get:url withHeaders:nil withCompleteBlock:^(QNResponseInfo *info, NSDictionary *resp) {
        if ([info isOK]) {
            QNAutoZoneInfo *info = [self buildInfoFromJson:resp];
            if (info == nil) {
                ret(kQNInvalidToken);
            } else {
                ret(0);
                [lock lock];
                [cache setValue:info forKey:[token index]];
                [lock unlock];
                if (dns != nil) {
                    QNServiceAddress *address = [[QNServiceAddress alloc] init:info.upHttps ips:@[ info.upIp ]];
                    addServiceToDns(address, dns);
                    address = [[QNServiceAddress alloc] init:info.upHost ips:@[ info.upIp ]];
                    addServiceToDns(address, dns);
                    address = [[QNServiceAddress alloc] init:info.upBackup ips:@[ info.upIp ]];
                    addServiceToDns(address, dns);
                }
            }
        } else {
            ret(kQNNetworkError);
        }
    }];
}

@end

@implementation QNZone

- (instancetype)init {
    self = [super init];
    return self;
}

/**
 *    备用上传服务器地址
 */
- (QNServiceAddress *)upBackup:(QNUpToken *)token {
    return nil;
}

- (QNServiceAddress *)up:(QNUpToken *)token {
    return nil;
}

+ (instancetype)createWithHost:(NSString *)up backupHost:(NSString *)backup ip1:(NSString *)ip1 ip2:(NSString *)ip2 {
    NSArray *ips = [NSArray arrayWithObjects:ip1, ip2, nil];
    NSString *a = [NSString stringWithFormat:@"http://%@", up];
    QNServiceAddress *s1 = [[QNServiceAddress alloc] init:a ips:ips];
    NSString *b = [NSString stringWithFormat:@"http://%@", backup];
    QNServiceAddress *s2 = [[QNServiceAddress alloc] init:b ips:ips];
    return [[QNFixedZone alloc] initWithUp:s1 upBackup:s2];
}

+ (instancetype)zone0 {
    static QNZone *z0 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        z0 = [QNZone createWithHost:@"upload.qiniu.com" backupHost:@"up.qiniu.com" ip1:@"183.136.139.10" ip2:@"115.231.182.136"];
    });
    return z0;
}

+ (instancetype)zone1 {
    static QNZone *z1 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        z1 = [QNZone createWithHost:@"upload-z1.qiniu.com" backupHost:@"up-z1.qiniu.com" ip1:@"106.38.227.28" ip2:@"106.38.227.27"];
    });
    return z1;
}

+ (instancetype)zone2 {
    static QNZone *z2 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        z2 = [QNZone createWithHost:@"upload-z2.qiniu.com" backupHost:@"up-z2.qiniu.com" ip1:@"14.152.37.7" ip2:@"183.60.214.199"];
    });
    return z2;
}

+ (instancetype)zoneNa0 {
    static QNZone *zNa0 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zNa0 = [QNZone createWithHost:@"upload-na0.qiniu.com" backupHost:@"up-na0.qiniu.com" ip1:@"14.152.37.7" ip2:@"183.60.214.199"];
    });
    return zNa0;
}

+ (void)addIpToDns:(QNDnsManager *)dns {
    addZoneToDns([QNZone zone0], dns);
    addZoneToDns([QNZone zone1], dns);
    addZoneToDns([QNZone zone2], dns);
}

- (void)preQuery:(QNUpToken *)token
              on:(QNPrequeryReturn)ret {
    ret(0);
}

@end
