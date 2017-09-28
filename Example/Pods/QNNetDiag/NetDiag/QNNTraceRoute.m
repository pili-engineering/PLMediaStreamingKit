//
//  QNNTraceRoute.m
//  NetDiag
//
//  Created by bailong on 16/1/26.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>

#import <netinet/in.h>
#import <netinet/tcp.h>

#import <sys/select.h>
#import <sys/time.h>

#import "QNNQue.h"
#import "QNNTraceRoute.h"

@interface QNNTraceRouteRecord : NSObject
@property (readonly) NSInteger hop;
@property NSString* ip;
@property NSTimeInterval* durations; //ms
@property (readonly) NSInteger count; //ms
@end

@implementation QNNTraceRouteRecord

- (instancetype)init:(NSInteger)hop
               count:(NSInteger)count {
    if (self = [super init]) {
        _ip = nil;
        _hop = hop;
        _durations = (NSTimeInterval*)calloc(count, sizeof(NSTimeInterval));
        _count = count;
    }
    return self;
}

- (NSString*)description {
    NSMutableString* ttlRecord = [[NSMutableString alloc] initWithCapacity:20];
    [ttlRecord appendFormat:@"%ld\t", (long)_hop];
    if (_ip == nil) {
        [ttlRecord appendFormat:@" \t"];
    } else {
        [ttlRecord appendFormat:@"%@\t", _ip];
    }
    for (int i = 0; i < _count; i++) {
        if (_durations[i] <= 0) {
            [ttlRecord appendFormat:@"*\t"];
        } else {
            [ttlRecord appendFormat:@"%.3f ms\t", _durations[i] * 1000];
        }
    }
    return ttlRecord;
}

- (void)dealloc {
    free(_durations);
}
@end

@implementation QNNTraceRouteResult

- (instancetype)init:(NSInteger)code
                  ip:(NSString*)ip
             content:(NSString*)content {
    if (self = [super init]) {
        _code = code;
        _ip = ip;
        _content = content;
    }
    return self;
}

@end

@interface QNNTraceRoute ()
@property (readonly) NSString* host;
@property (nonatomic, strong) id<QNNOutputDelegate> output;
@property (readonly) QNNTraceRouteCompleteHandler complete;

@property (readonly) NSInteger maxTtl;
@property (atomic) NSInteger stopped;
@property (nonatomic, strong) NSMutableString* contentString;

@end

@implementation QNNTraceRoute

- (instancetype)init:(NSString*)host
              output:(id<QNNOutputDelegate>)output
            complete:(QNNTraceRouteCompleteHandler)complete
              maxTtl:(NSInteger)maxTtl {
    if (self = [super init]) {
        _host = host;
        _output = output;
        _complete = complete;
        _maxTtl = maxTtl;
        _stopped = NO;
        _contentString = [[NSMutableString alloc] init];
    }
    return self;
}

static const int TraceMaxAttempts = 3;

- (NSInteger)sendAndRecv:(int)sendSock
                    recv:(int)icmpSock
                    addr:(struct sockaddr_in*)addr
                     ttl:(int)ttl
                      ip:(in_addr_t*)ipOut {
    int err = 0;
    struct sockaddr_in storageAddr;
    socklen_t n = sizeof(struct sockaddr);
    static char cmsg[] = "qiniu diag\n";
    char buff[100];

    QNNTraceRouteRecord* record = [[QNNTraceRouteRecord alloc] init:ttl count:TraceMaxAttempts];
    for (int try = 0; try < TraceMaxAttempts; try ++) {
        NSDate* startTime = [NSDate date];
        ssize_t sent = sendto(sendSock, cmsg, sizeof(cmsg), 0, (struct sockaddr*)addr, sizeof(struct sockaddr));
        if (sent != sizeof(cmsg)) {
            err = errno;
            NSLog(@"error %s", strerror(err));
            [self.output write:[NSString stringWithFormat:@"send error %s\n", strerror(err)]];
            break;
        }

        struct timeval tv;
        fd_set readfds;
        tv.tv_sec = 3;
        tv.tv_usec = 0;
        FD_ZERO(&readfds);
        FD_SET(icmpSock, &readfds);
        select(icmpSock + 1, &readfds, NULL, NULL, &tv);
        if (FD_ISSET(icmpSock, &readfds) > 0) {
            ssize_t res = recvfrom(icmpSock, buff, sizeof(buff), 0, (struct sockaddr*)&storageAddr, &n);
            if (res < 0) {
                err = errno;
                [self.output write:[NSString stringWithFormat:@"recv error %s\n", strerror(err)]];
                break;
            } else {
                NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
                char ip[16] = {0};
                inet_ntop(AF_INET, &storageAddr.sin_addr.s_addr, ip, sizeof(ip));
                *ipOut = storageAddr.sin_addr.s_addr;
                NSString* remoteAddress = [NSString stringWithFormat:@"%s", ip];
                record.ip = remoteAddress;
                record.durations[try] = duration;
            }
        }

        if (_stopped) {
            break;
        }
    }
    [_output write:[NSString stringWithFormat:@"%@\n", record]];
    [_contentString appendString:[NSString stringWithFormat:@"%@\n", record]];

    return err;
}

- (void)run {
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(30002);
    addr.sin_addr.s_addr = inet_addr([_host UTF8String]);
    [self.output write:[NSString stringWithFormat:@"traceroute to %@ ...\n", _host]];
    if (addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent* host = gethostbyname([_host UTF8String]);
        if (host == NULL || host->h_addr == NULL) {
            [self.output write:@"Problem accessing the DNS"];
            if (_complete != nil) {
                [QNNQue async_run_main:^(void) {
                    QNNTraceRouteResult* result = [[QNNTraceRouteResult alloc] init:-1006 ip:nil content:nil];
                    _complete(result);
                }];
            }
            return;
        }
        addr.sin_addr = *(struct in_addr*)host->h_addr;
        [self.output write:[NSString stringWithFormat:@"traceroute to ip %s ...\n", inet_ntoa(addr.sin_addr)]];
    }

    int recv_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
    if (-1 == fcntl(recv_sock, F_SETFL, O_NONBLOCK)) {
        NSLog(@"fcntl socket error!");
        if (_complete != nil) {
            [QNNQue async_run_main:^(void) {
                QNNTraceRouteResult* result = [[QNNTraceRouteResult alloc] init:-1 ip:[NSString stringWithUTF8String:inet_ntoa(addr.sin_addr)] content:nil];
                _complete(result);
            }];
        }
        close(recv_sock);
        return;
    }

    int send_sock = socket(AF_INET, SOCK_DGRAM, 0);

    int ttl = 1;
    in_addr_t ip = 0;
    NSDate* startDate = [NSDate date];
    do {
        int t = setsockopt(send_sock, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
        if (t < 0) {
            NSLog(@"errro %s\n", strerror(t));
        }
        [self sendAndRecv:send_sock recv:recv_sock addr:&addr ttl:ttl ip:&ip];
    } while (++ttl <= _maxTtl && !_stopped && ip != addr.sin_addr.s_addr && [[NSDate date] timeIntervalSinceDate:startDate] <= 20);

    close(send_sock);
    close(recv_sock);

    NSInteger code = 0;
    if (_stopped) {
        code = kQNNRequestStoped;
    }
    [QNNQue async_run_main:^(void) {
        QNNTraceRouteResult* result = [[QNNTraceRouteResult alloc] init:code ip:[NSString stringWithUTF8String:inet_ntoa(addr.sin_addr)] content:_contentString];
        _complete(result);
    }];
}

+ (instancetype)start:(NSString*)host
               output:(id<QNNOutputDelegate>)output
             complete:(QNNTraceRouteCompleteHandler)complete {
    return [QNNTraceRoute start:host output:output complete:complete maxTtl:30];
}

+ (instancetype)start:(NSString*)host
               output:(id<QNNOutputDelegate>)output
             complete:(QNNTraceRouteCompleteHandler)complete
               maxTtl:(NSInteger)maxTtl {
    QNNTraceRoute* t = [[QNNTraceRoute alloc] init:host output:output complete:complete maxTtl:maxTtl];

    [QNNQue async_run_serial:^(void) {
        [t run];
    }];

    return t;
}

- (void)stop {
    _stopped = YES;
}
@end
