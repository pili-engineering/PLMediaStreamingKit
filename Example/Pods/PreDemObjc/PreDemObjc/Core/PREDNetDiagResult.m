//
//  PREDNetDiagResult.m
//  PreDemObjc
//
//  Created by WangSiyu on 25/05/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDNetDiagResult.h"
#import "PREDManagerPrivate.h"
#import "PREDHelper.h"
#import "PREDLogger.h"
#import "QNNetDiag.h"

#define PREDTotalResultNeeded   5

@implementation PREDNetDiagResult {
    NSInteger _completedCount;
    NSLock *_lock;
    PREDNetDiagCompleteHandler _complete;
    PREDNetworkClient *_client;
}

- (instancetype)initWithComplete:(PREDNetDiagCompleteHandler)complete netClient:(PREDNetworkClient *)client {
    if (self = [super init]) {
        _completedCount = 0;
        _lock = [NSLock new];
        _complete = complete;
        _client = client;
        self.app_bundle_id = PREDHelper.appBundleId;
        self.app_name = PREDHelper.appName;
        self.app_version = PREDHelper.appVersion;
        self.device_model = PREDHelper.deviceModel;
        self.os_platform = PREDHelper.osPlatform;
        self.os_version = PREDHelper.osVersion;
        self.sdk_version = PREDHelper.sdkVersion;
        self.sdk_id = PREDHelper.UUID;
        self.device_id = @"";
    }
    return self;
}

- (void)gotTcpResult:(QNNTcpPingResult *)r {
    self.tcp_code = r.code;
    self.tcp_ip = r.ip;
    self.tcp_max_time = r.maxTime;
    self.tcp_min_time = r.minTime;
    self.tcp_avg_time = r.avgTime;
    self.tcp_loss = r.loss;
    self.tcp_count = r.count;
    self.tcp_total_time = r.totalTime;
    self.tcp_stddev = r.stddev;
    [self checkAndSend];
}

- (void)gotPingResult:(QNNPingResult *)r {
    self.ping_code = r.code;
    self.ping_ip = r.ip;
    self.ping_size = r.size;
    self.ping_max_rtt = r.maxRtt;
    self.ping_min_rtt = r.minRtt;
    self.ping_avg_rtt = r.avgRtt;
    self.ping_loss = r.loss;
    self.ping_count = r.count;
    self.ping_total_time = r.totalTime;
    self.ping_stddev = r.stddev;
    [self checkAndSend];
}

- (void)gotHttpResult:(QNNHttpResult *)r {
    self.http_code = r.code;
    self.http_ip = r.ip;
    self.http_duration = r.duration;
    self.http_body_size = r.body.length;
    [self checkAndSend];
}

- (void)gotTrResult:(QNNTraceRouteResult *)r {
    self.tr_code = r.code;
    self.tr_ip = r.ip;
    self.tr_content = r.content;
    [self checkAndSend];
}

- (void)gotNsLookupResult:(NSArray<QNNRecord *> *) r {
    NSMutableString *recordString = [[NSMutableString alloc] initWithCapacity:30];
    for (QNNRecord *record in r) {
        [recordString appendFormat:@"%@\t", record.value];
        [recordString appendFormat:@"%d\t", record.ttl];
        [recordString appendFormat:@"%d\n", record.type];
    }
    self.dns_records = recordString;
    [self checkAndSend];
}

- (NSDictionary *)toDic {
    return [PREDHelper getObjectData:self];
}

- (void)checkAndSend {
    [_lock lock];
    _completedCount++;
    if (_completedCount == PREDTotalResultNeeded) {
        [_lock unlock];
        [self generateResultID];
        _complete(self);
        [self sendReport];
    } else {
        [_lock unlock];
    }
}

- (void)generateResultID {
    self.result_id = [PREDHelper MD5:[NSString stringWithFormat:@"%f%@%@%@", [[NSDate date] timeIntervalSince1970], self.ping_ip, self.tr_content, self.dns_records]];
}

- (void)sendReport {
    [_client postPath:@"net-diags/i" parameters:[self toDic] completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
        if (error || operation.response.statusCode >= 400) {
            PREDLogError(@"send net diag error: %@, statusCode: %ld", error, (long)operation.response.statusCode);
        }
    }];
}

@end
