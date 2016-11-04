//
//  QNNRtmp.m
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

#include <netinet/in.h>
#include <netinet/tcp.h>

#import "QNNRtmp.h"

const int kQNNRtmpServerVersionError = -20001;
const int kQNNRtmpServerSignatureError = -20002;
const int kQNNRtmpServerTimeError = -20003;

#define RTMP_SIG_SIZE 1536

/* needs to fit largest number of bytes recv() may return */
#define RTMP_BUFFER_CACHE_SIZE (16 * 1024)

struct sock_ret {
    int count;
    int error_code;
};

//static BOOL isTimeout(int sockerr){
//    return sockerr == EWOULDBLOCK || sockerr == EAGAIN;
//}

static struct sock_ret readIntoBuffer(int sock, char* buf, int buf_size) {
    ssize_t n = 0;
    int sockerr = 0;
    while (1) {
        n = recv(sock, buf, buf_size, 0);
        if (n == -1) {
            sockerr = errno;
            if (sockerr == EINTR) {
                continue;
            }
        }
        break;
    }

    struct sock_ret ret;
    ret.count = (int)n;
    ret.error_code = sockerr;
    return ret;
}

static struct sock_ret readAll(int sock, char* buffer, int size) {
    int pos = 0;
    struct sock_ret ret;
    ret.count = 0;
    ret.error_code = 0;
    while (pos < size) {
        ret = readIntoBuffer(sock, buffer + pos, size - pos);
        if (ret.count == -1) {
            return ret;
        }
        pos += ret.count;
    }
    return ret;
}

static struct sock_ret writeAll(int sock, const char* buffer, int n) {
    const char* ptr = buffer;
    struct sock_ret ret;
    ret.count = 0;
    ret.error_code = 0;
    while (n > 0) {
        ssize_t nBytes = send(sock, buffer, n, 0);
        if (nBytes < 0) {
            int sockerr = errno;
            if (sockerr == EINTR) {
                continue;
            }
            ret.count = -1;
            ret.error_code = sockerr;
            return ret;
        }

        if (nBytes == 0) {
            break;
        }

        n -= nBytes;
        ptr += nBytes;
    }
    ret.count = (int)(ptr - buffer);

    return ret;
}

static char* init_c0_c1(char* buff) {
    buff[0] = 0x03; /* not encrypted */
    char* client_sig = buff + 1;
    uint32_t uptime = htonl(0); // get time, to do
    memcpy(client_sig, &uptime, 4);

    memset(&client_sig[4], 0, 4);

    for (int i = 8; i < RTMP_SIG_SIZE; i++) {
        client_sig[i] = (char)(rand() % 256);
    }
    return buff;
}

static struct sock_ret send_c0_c1(int sock, char* c0_c1) {
    return writeAll(sock, c0_c1, RTMP_SIG_SIZE + 1);
}

static struct sock_ret send_c2(int sock, char* c2) {
    return writeAll(sock, c2, RTMP_SIG_SIZE);
}

static int verify_s0_s1(int sock, char* s0_s1) {
    struct sock_ret ret = readAll(sock, s0_s1, RTMP_SIG_SIZE + 1);
    if (ret.count == -1) {
        return ret.error_code;
    }
    char s0 = s0_s1[0];
    if (s0 != 0x03) {
        return kQNNRtmpServerVersionError;
    }

    return 0;
}

static int verify_s2(int sock, char* server_sig, char* client_sig) {
    struct sock_ret ret = readAll(sock, server_sig, RTMP_SIG_SIZE);
    if (ret.error_code != 0) {
        return ret.error_code;
    }
    if (memcmp(server_sig, server_sig, RTMP_SIG_SIZE) != 0) {
        return kQNNRtmpServerSignatureError;
    }
    return 0;
}

@interface QNNRtmpHandshakeResult ()

- (instancetype)init:(NSInteger)code
                 max:(NSTimeInterval)maxTime
                 min:(NSTimeInterval)minTime
                 avg:(NSTimeInterval)avgTime
               count:(NSInteger)count;
@end

@implementation QNNRtmpHandshakeResult

- (NSString*)description {
    if (_code == 0) {
        return [NSString stringWithFormat:@"tcp connect min/avg/max = %f/%f/%fms", _minTime, _avgTime, _maxTime];
    }
    return [NSString stringWithFormat:@"tcp connect failed %ld", (long)_code];
}

- (instancetype)init:(NSInteger)code
                 max:(NSTimeInterval)maxTime
                 min:(NSTimeInterval)minTime
                 avg:(NSTimeInterval)avgTime
               count:(NSInteger)count {
    if (self = [super init]) {
        _code = code;
        _minTime = minTime;
        _avgTime = avgTime;
        _maxTime = maxTime;
        _count = count;
    }
    return self;
}

@end

@interface QNNRtmpHandshake ()

@property (readonly) NSString* host;
@property (readonly) NSUInteger port;
@property (readonly) id<QNNOutputDelegate> output;
@property (readonly) QNNRtmpHandshakeCompleteHandler complete;
@property (readonly) NSInteger interval;
@property (readonly) NSInteger count;
@property (atomic) BOOL stopped;
@property NSUInteger index;
@end

@implementation QNNRtmpHandshake

- (instancetype)init:(NSString*)host
                port:(NSInteger)port
              output:(id<QNNOutputDelegate>)output
            complete:(QNNRtmpHandshakeCompleteHandler)complete
               count:(NSInteger)count {
    if (self = [super init]) {
        _host = host;
        _port = port;
        _output = output;
        _complete = complete;
        _count = count;
        _stopped = NO;
    }
    return self;
}

- (void)run {
    [self.output write:[NSString stringWithFormat:@"connect to host %@:%lu ...\n", _host, (unsigned long)_port]];
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);
    addr.sin_addr.s_addr = inet_addr([_host UTF8String]);
    if (addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent* host = gethostbyname([_host UTF8String]);
        if (host == NULL || host->h_addr == NULL) {
            [self.output write:@"Problem accessing the DNS"];
            if (_complete != nil) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    _complete([self buildResult:-1006 durations:nil count:0]);
                });
            }
            return;
        }
        addr.sin_addr = *(struct in_addr*)host->h_addr;
        [self.output write:[NSString stringWithFormat:@"connect to ip %s:%lu ...\n", inet_ntoa(addr.sin_addr), (unsigned long)_port]];
    }

    NSTimeInterval* intervals = (NSTimeInterval*)malloc(sizeof(NSTimeInterval) * _count);
    NSInteger index = 0;
    NSInteger r = 0;
    do {
        NSDate* t1 = [NSDate date];

        r = [self handShake:&addr start:t1];

        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:t1];
        intervals[_index] = duration;
        if (r == 0) {
            [self.output write:[NSString stringWithFormat:@"rtmp handshake to %s:%lu, %f ms\n", inet_ntoa(addr.sin_addr), (unsigned long)_port, duration * 1000]];
        } else {
            [self.output write:[NSString stringWithFormat:@"rtmp handshake failed to %s:%lu, %f ms, error %ld\n", inet_ntoa(addr.sin_addr), (unsigned long)_port, duration * 1000, (long)r]];
        }

        if (index < _count && !_stopped && r == 0) {
            [NSThread sleepForTimeInterval:0.1];
        }
    } while (++index < _count && !_stopped && r == 0);

    if (_complete) {
        NSInteger code = r;
        if (_stopped) {
            code = kQNNRequestStoped;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            _complete([self buildResult:code durations:intervals count:index]);
        });
    }
    free(intervals);
}

- (QNNRtmpHandshakeResult*)buildResult:(NSInteger)code
                             durations:(NSTimeInterval*)durations
                                 count:(NSInteger)count {
    if (code != 0 && code != kQNNRequestStoped) {
        return [[QNNRtmpHandshakeResult alloc] init:code max:0 min:0 avg:0 count:1];
    }
    NSTimeInterval max = 0;
    NSTimeInterval min = 10000000;
    NSTimeInterval sum = 0;
    for (int i = 0; i < count; i++) {
        if (durations[i] > max) {
            max = durations[i];
        }
        if (durations[i] < min) {
            min = durations[i];
        }
        sum += durations[i];
    }
    NSTimeInterval avg = sum / count;
    return [[QNNRtmpHandshakeResult alloc] init:code max:max min:min avg:avg count:count];
}

- (int)handShakeSocket:(int)sock {
    char client_buf[RTMP_SIG_SIZE + 1], *client_sig = client_buf + 1;
    char server_buf[RTMP_SIG_SIZE + 1], *server_sig = server_buf + 1;
    char* c0_c1 = init_c0_c1(client_buf);
    struct sock_ret ret = send_c0_c1(sock, c0_c1);
    if (ret.count == -1) {
        close(sock);
        return ret.error_code;
    }

    int r = verify_s0_s1(sock, server_buf);
    if (r != 0) {
        close(sock);
        return r;
    }

    ret = send_c2(sock, server_sig);
    if (ret.count == -1) {
        close(sock);
        return ret.error_code;
    }

    r = verify_s2(sock, server_sig, client_sig);
    close(sock);
    return ret.error_code;
}

- (NSInteger)handShake:(struct sockaddr_in*)addr
                 start:(NSDate*)start {
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == -1) {
        return errno;
    }
    int on = 1;
    setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, (char*)&on, sizeof(on));

    struct timeval timeout;
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout));
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (char*)&timeout, sizeof(timeout));

    if (connect(sock, (struct sockaddr*)addr, sizeof(struct sockaddr)) < 0) {
        int err = errno;
        close(sock);
        return err;
    }
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:start];
    [self.output write:[NSString stringWithFormat:@"rtmp connect to %s:%lu, %f ms\n", inet_ntoa(addr->sin_addr), (unsigned long)_port, duration * 1000]];
    return [self handShakeSocket:sock];
}

+ (instancetype)start:(NSString*)host
               output:(id<QNNOutputDelegate>)output
             complete:(QNNRtmpHandshakeCompleteHandler)complete {
    return [QNNRtmpHandshake start:host port:1935 count:2 output:output complete:complete];
}

+ (instancetype)start:(NSString*)host
                 port:(NSUInteger)port
                count:(NSInteger)count
               output:(id<QNNOutputDelegate>)output
             complete:(QNNRtmpHandshakeCompleteHandler)complete;
{
    QNNRtmpHandshake* t = [[QNNRtmpHandshake alloc] init:host
                                                    port:port
                                                  output:output
                                                complete:complete
                                                   count:count];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [t run];
    });
    return t;
}

- (void)stop {
    _stopped = YES;
}

@end