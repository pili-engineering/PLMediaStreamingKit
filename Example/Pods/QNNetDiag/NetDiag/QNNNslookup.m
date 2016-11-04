//
//  QNNNslookup.m
//  NetDiag
//
//  Created by bailong on 16/2/2.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#include <arpa/inet.h>
#include <resolv.h>
#include <string.h>

#import "QNNNslookup.h"

const int kQNNTypeA = 1;
const int kQNNTypeCname = 5;

@implementation QNNRecord

- (instancetype)init:(NSString *)value
                 ttl:(int)ttl
                type:(int)type {
    if (self = [super init]) {
        _ttl = ttl;
        _value = value;
        _type = type;
    }
    return self;
}

- (NSString *)description {
    NSString *type;
    if (_type == kQNNTypeA) {
        type = @"A";
    } else if (_type == kQNNTypeCname) {
        type = @"CNAME";
    } else {
        type = [NSString stringWithFormat:@"TYPE-%d", _type];
    }
    return [NSString stringWithFormat:@"%d IN %@ %@", _ttl, type, _value];
}

@end

static NSArray *query_ip(res_state res, const char *host) {
    u_char answer[1500];
    int len = res_nquery(res, host, ns_c_in, ns_t_a, answer, sizeof(answer));

    ns_msg handle;
    ns_initparse(answer, len, &handle);

    int count = ns_msg_count(handle, ns_s_an);
    if (count <= 0) {
        return nil;
    }
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
    char buf[32];
    char cnameBuf[NS_MAXDNAME];
    memset(cnameBuf, 0, sizeof(cnameBuf));
    for (int i = 0; i < count; i++) {
        ns_rr rr;
        if (ns_parserr(&handle, ns_s_an, i, &rr) != 0) {
            return nil;
        }
        int t = ns_rr_type(rr);
        int ttl = ns_rr_ttl(rr);
        NSString *val;
        if (t == ns_t_a) {
            const char *p = inet_ntop(AF_INET, ns_rr_rdata(rr), buf, 32);
            val = [NSString stringWithUTF8String:p];
        } else if (t == ns_t_cname) {
            int x = ns_name_uncompress(answer, &(answer[len]), ns_rr_rdata(rr), cnameBuf, sizeof(cnameBuf));
            if (x <= 0) {
                continue;
            }
            val = [NSString stringWithUTF8String:cnameBuf];
            memset(cnameBuf, 0, sizeof(cnameBuf));
        } else {
            continue;
        }

        QNNRecord *record = [[QNNRecord alloc] init:val ttl:ttl type:t];
        [array addObject:record];
    }
    res_ndestroy(res);
    return array;
}

static int setup_dns_server(res_state res, const char *dns_server) {
    int r = res_ninit(res);
    if (r != 0) {
        return r;
    }
    if (dns_server == NULL) {
        return 0;
    }
    struct in_addr addr;
    r = inet_aton(dns_server, &addr);
    if (r == 0) {
        return -1;
    }

    res->nsaddr_list[0].sin_addr = addr;
    res->nsaddr_list[0].sin_family = AF_INET;
    res->nsaddr_list[0].sin_port = htons(NS_DEFAULTPORT);
    res->nscount = 1;
    return 0;
}

@interface QNNNslookup ()

@property (readonly) NSString *domain;
@property (readonly) id<QNNOutputDelegate> output;
@property (readonly) QNNNslookupCompleteHandler complete;
@property (readonly) NSString *dnsServer;
@property (atomic) BOOL stopped;

@end

@implementation QNNNslookup

- (instancetype)init:(NSString *)domain
              server:(NSString *)dnsServer
              output:(id<QNNOutputDelegate>)output
            complete:(QNNNslookupCompleteHandler)complete {
    if (self = [super init]) {
        _domain = domain;
        _dnsServer = dnsServer;
        _output = output;
        _complete = complete;
        _stopped = NO;
    }
    return self;
}

- (void)run {
    if (_output != nil) {
        [_output write:[NSString stringWithFormat:@"Query: %@", _domain]];
        if (_dnsServer == nil) {
            [_output write:@"system dns server\n"];
        } else {
            [_output write:[NSString stringWithFormat:@"server: %@", _dnsServer]];
        }
    }

    struct __res_state res;

    int r;
    NSDate *t1 = [NSDate date];
    if (_dnsServer == nil) {
        r = setup_dns_server(&res, NULL);
    } else {
        r = setup_dns_server(&res, [_dnsServer cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    if (r != 0) {
        return;
    }

    NSArray *records = query_ip(&res, [_domain cStringUsingEncoding:NSUTF8StringEncoding]);
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:t1];
    if (_output) {
        [_output write:[NSString stringWithFormat:@"Query time: %f msec\n", duration * 1000]];
        for (QNNRecord *r in records) {
            [_output write:[NSString stringWithFormat:@"%@\n", r]];
        }
    }

    if (_complete) {
        _complete(records);
    }
}

+ (instancetype)start:(NSString *)domain
               output:(id<QNNOutputDelegate>)output
             complete:(QNNNslookupCompleteHandler)complete {
    return [QNNNslookup start:domain server:nil output:output complete:complete];
}

+ (instancetype)start:(NSString *)domain
               server:(NSString *)dnsServer
               output:(id<QNNOutputDelegate>)output
             complete:(QNNNslookupCompleteHandler)complete {
    QNNNslookup *instance = [[QNNNslookup alloc] init:domain server:dnsServer output:output complete:complete];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [instance run];
    });
    return instance;
}

- (void)stop {
    _stopped = YES;
}

@end
