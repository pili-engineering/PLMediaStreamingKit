//
//  QNNHttp.m
//  NetDiag
//
//  Created by bailong on 16/2/10.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNHttp.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>

@implementation QNNHttpResult

- (NSString *)description {
    NSString *bodySummary = @"";
    if (_body != nil) {
        NSString *str = [[NSString alloc] initWithData:_body encoding:NSUTF8StringEncoding];
        if (str == nil) {
            bodySummary = @"not utf8 string body";
        }
    }
    return [NSString stringWithFormat:@"code:%ld duration:%f body:%@", (long)_code, _duration, bodySummary];
}

- (instancetype)init:(NSInteger)code
                  ip:(NSString *)ip
            duration:(NSTimeInterval)duration
             headers:(NSDictionary *)headers
                body:(NSData *)body {
    if (self = [super init]) {
        _code = code;
        _ip = ip;
        _duration = duration;
        _headers = headers;
        _body = body;
    }
    return self;
}

@end

@interface QNNHttp ()
@property (readonly) NSString *url;
@property (readonly) id<QNNOutputDelegate> output;
@property (readonly) QNNHttpCompleteHandler complete;
@end

@implementation QNNHttp

- (instancetype)init:(NSString *)url
              output:(id<QNNOutputDelegate>)output
            complete:(QNNHttpCompleteHandler)complete {
    if (self = [super init]) {
        _url = url;
        _output = output;
        _complete = complete;
    }
    return self;
}

- (NSString *)reserveUrlToIp {
    NSString *ip = nil;
    NSString *urlStr = [[_url componentsSeparatedByString:@"//"] lastObject];

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(80);
    addr.sin_addr.s_addr = inet_addr([urlStr UTF8String]);
    if (addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *host = gethostbyname([urlStr UTF8String]);
        if (host == NULL || host->h_addr == NULL) {
            return ip;
        }
        addr.sin_addr = *(struct in_addr *)host->h_addr;
        ip = [NSString stringWithUTF8String:inet_ntoa(addr.sin_addr)];
    }
    return ip;
}

- (void)run {
    if (_output) {
        [_output write:[NSString stringWithFormat:@"GET %@", _url]];
    }

    NSDate *t1 = [NSDate date];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [urlRequest setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response = nil;
    NSError *httpError = nil;
    NSData *d = [NSURLConnection sendSynchronousRequest:urlRequest
                                      returningResponse:&response
                                                  error:&httpError];
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:t1] * 1000;
    if (_output) {
        if (httpError != nil) {
            [_output write:[httpError description]];
        }
        [_output write:[NSString stringWithFormat:@"complete duration:%f status %ld\n", duration, (long)response.statusCode]];
        if (response != nil && response.allHeaderFields != nil) {
            [response.allHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
                [_output write:[NSString stringWithFormat:@"%@: %@\n", key, obj]];
            }];
        }
    }
    if (_complete == nil) {
        return;
    }
    if (httpError != nil) {
        QNNHttpResult *result = [[QNNHttpResult alloc] init:httpError.code ip:[self reserveUrlToIp] duration:duration headers:nil body:nil];
        _complete(result);
        return;
    }

    QNNHttpResult *result = [[QNNHttpResult alloc] init:response.statusCode ip:[self reserveUrlToIp] duration:duration headers:response.allHeaderFields body:d];
    _complete(result);
}

+ (instancetype)start:(NSString *)url
               output:(id<QNNOutputDelegate>)output
             complete:(QNNHttpCompleteHandler)complete {
    QNNHttp *http = [[QNNHttp alloc] init:url output:output complete:complete];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [http run];
    });
    return http;
}

- (void)stop {
}

@end