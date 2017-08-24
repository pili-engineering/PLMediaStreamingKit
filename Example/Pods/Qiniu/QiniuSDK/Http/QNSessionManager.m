//
//  QNHttpManager.m
//  QiniuSDK
//
//  Created by bailong on 14/10/1.
//  Copyright (c) 2014年 Qiniu. All rights reserved.
//

#import "AFNetworking.h"

#import "HappyDNS.h"
#import "QNAsyncRun.h"
#import "QNConfiguration.h"
#import "QNResponseInfo.h"
#import "QNSessionManager.h"
#include "QNSystem.h"
#import "QNUserAgent.h"

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)

@interface QNProgessDelegate : NSObject
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@property (nonatomic, strong) QNInternalProgressBlock progressBlock;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSURLSessionUploadTask *task;
@property (nonatomic, strong) QNCancelBlock cancelBlock;
- (instancetype)initWithProgress:(QNInternalProgressBlock)progressBlock;
@end

static NSURL *buildUrl(NSString *host, NSNumber *port, NSString *path) {
    port = port == nil ? [NSNumber numberWithInt:80] : port;
    NSString *p = [[NSString alloc] initWithFormat:@"http://%@:%@%@", host, port, path];
    return [[NSURL alloc] initWithString:p];
}

static BOOL needRetry(NSHTTPURLResponse *httpResponse, NSError *error) {
    if (error != nil) {
        return error.code < -1000;
    }
    if (httpResponse == nil) {
        return YES;
    }
    int status = (int)httpResponse.statusCode;
    return status >= 500 && status < 600 && status != 579;
}

@implementation QNProgessDelegate
- (instancetype)initWithProgress:(QNInternalProgressBlock)progressBlock {
    if (self = [super init]) {
        _progressBlock = progressBlock;
        _progress = nil;
    }

    return self;
}

- (void)valueChange:(NSProgress *)uploadProgress {
    _progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
    if (_cancelBlock && _cancelBlock()) {
        [_task cancel];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (context == nil || object == nil) {
        return;
    }

    NSProgress *progress = (NSProgress *)object;

    void *p = (__bridge void *)(self);
    if (p == context) {
        _progressBlock(progress.completedUnitCount, progress.totalUnitCount);
        if (_cancelBlock && _cancelBlock()) {
            [_task cancel];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

@interface QNSessionManager ()
@property (nonatomic) AFHTTPSessionManager *httpManager;
@property UInt32 timeout;
@property (nonatomic, strong) QNUrlConvert converter;
@property bool noProxy;
@property (nonatomic) QNDnsManager *dns;
@end

@implementation QNSessionManager

- (instancetype)initWithProxy:(NSDictionary *)proxyDict
                      timeout:(UInt32)timeout
                 urlConverter:(QNUrlConvert)converter
                          dns:(QNDnsManager *)dns {
    if (self = [super init]) {
        if (proxyDict != nil) {
            _noProxy = NO;
        } else {
            _noProxy = YES;
        }

        _httpManager = [QNSessionManager httpManagerWithProxy:proxyDict];

        _timeout = timeout;
        _converter = converter;
        _dns = dns;
    }

    return self;
}

+ (AFHTTPSessionManager *)httpManagerWithProxy:(NSDictionary *)proxyDict {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (proxyDict != nil) {
        configuration.connectionProxyDictionary = proxyDict;
    }

    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return httpManager;
}

- (instancetype)init {
    return [self initWithProxy:nil timeout:60 urlConverter:nil dns:nil];
}

+ (QNResponseInfo *)buildResponseInfo:(NSHTTPURLResponse *)response
                            withError:(NSError *)error
                         withDuration:(double)duration
                         withResponse:(NSData *)body
                             withHost:(NSString *)host
                               withIp:(NSString *)ip {
    QNResponseInfo *info;

    if (response) {
        int status = (int)[response statusCode];
        NSDictionary *headers = [response allHeaderFields];
        NSString *reqId = headers[@"X-Reqid"];
        NSString *xlog = headers[@"X-Log"];
        NSString *xvia = headers[@"X-Via"];
        if (xvia == nil) {
            xvia = headers[@"X-Px"];
        }
        if (xvia == nil) {
            xvia = headers[@"Fw-Via"];
        }
        info = [[QNResponseInfo alloc] init:status withReqId:reqId withXLog:xlog withXVia:xvia withHost:host withIp:ip withDuration:duration withBody:body];
    } else {
        info = [QNResponseInfo responseInfoWithNetError:error host:host duration:duration];
    }
    return info;
}

- (void)sendRequest:(NSMutableURLRequest *)request
  withCompleteBlock:(QNCompleteBlock)completeBlock
  withProgressBlock:(QNInternalProgressBlock)progressBlock
    withCancelBlock:(QNCancelBlock)cancelBlock
         withAccess:(NSString *)access {
    __block NSDate *startTime = [NSDate date];
    NSString *domain = request.URL.host;
    NSString *u = request.URL.absoluteString;
    NSURL *url = request.URL;
    NSArray *ips = nil;
    if (_converter != nil) {
        url = [[NSURL alloc] initWithString:_converter(u)];
        request.URL = url;
        domain = url.host;
    } else if (_noProxy && _dns != nil && [url.scheme isEqualToString:@"http"]) {
        if (isIpV6FullySupported() || ![QNIP isV6]) {
            ips = [_dns queryWithDomain:[[QNDomain alloc] init:domain hostsFirst:NO hasCname:YES maxTtl:1000]];
            double duration = [[NSDate date] timeIntervalSinceDate:startTime];

            if (ips == nil || ips.count == 0) {
                NSError *error = [[NSError alloc] initWithDomain:domain code:-1003 userInfo:@{ @"error" : @"unkonwn host" }];

                QNResponseInfo *info = [QNResponseInfo responseInfoWithNetError:error host:domain duration:duration];
                NSLog(@"failure %@", info);

                completeBlock(info, nil);
                return;
            }
        }
    }
    [self sendRequest2:request withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock withIpArray:ips withIndex:0 withDomain:domain withRetryTimes:3 withStartTime:startTime withAccess:access];
}

- (void)sendRequest2:(NSMutableURLRequest *)request
   withCompleteBlock:(QNCompleteBlock)completeBlock
   withProgressBlock:(QNInternalProgressBlock)progressBlock
     withCancelBlock:(QNCancelBlock)cancelBlock
         withIpArray:(NSArray *)ips
           withIndex:(int)index
          withDomain:(NSString *)domain
      withRetryTimes:(int)times
       withStartTime:(NSDate *)startTime
          withAccess:(NSString *)access {
    NSURL *url = request.URL;
    __block NSString *ip = nil;
    if (ips != nil) {
        ip = [ips objectAtIndex:(index % ips.count)];
        NSString *path = url.path;
        if (path == nil || [@"" isEqualToString:path]) {
            path = @"/";
        }
        url = buildUrl(ip, url.port, path);
        [request setValue:domain forHTTPHeaderField:@"Host"];
    }
    request.URL = url;
    [request setTimeoutInterval:_timeout];
    [request setValue:[[QNUserAgent sharedInstance] getUserAgent:access] forHTTPHeaderField:@"User-Agent"];
    [request setValue:nil forHTTPHeaderField:@"Accept-Language"];
    if (progressBlock == nil) {
        progressBlock = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        };
    }
    QNInternalProgressBlock progressBlock2 = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
    };
    __block QNProgessDelegate *delegate = [[QNProgessDelegate alloc] initWithProgress:progressBlock2];

    NSURLSessionUploadTask *uploadTask = [_httpManager uploadTaskWithRequest:request fromData:nil progress:^(NSProgress *_Nonnull uploadProgress) {
        [delegate valueChange:uploadProgress];
    }
        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSData *data = responseObject;
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            double duration = [[NSDate date] timeIntervalSinceDate:startTime];
            QNResponseInfo *info;
            NSDictionary *resp = nil;
            if (_converter != nil && _noProxy && (index + 1 < ips.count || times > 0) && needRetry(httpResponse, error)) {
                [self sendRequest2:request withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock withIpArray:ips withIndex:index + 1 withDomain:domain withRetryTimes:times - 1 withStartTime:startTime withAccess:access];
                return;
            }
            if (error == nil) {
                info = [QNSessionManager buildResponseInfo:httpResponse withError:nil withDuration:duration withResponse:data withHost:domain withIp:ip];
                if (info.isOK) {
                    NSError *tmp;
                    resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&tmp];
                }
            } else {
                info = [QNSessionManager buildResponseInfo:httpResponse withError:error withDuration:duration withResponse:data withHost:domain withIp:ip];
            }
            completeBlock(info, resp);
        }];
    delegate.task = uploadTask;
    delegate.cancelBlock = cancelBlock;

    [uploadTask resume];
}

- (void)multipartPost:(NSString *)url
             withData:(NSData *)data
           withParams:(NSDictionary *)params
         withFileName:(NSString *)key
         withMimeType:(NSString *)mime
    withCompleteBlock:(QNCompleteBlock)completeBlock
    withProgressBlock:(QNInternalProgressBlock)progressBlock
      withCancelBlock:(QNCancelBlock)cancelBlock
           withAccess:(NSString *)access {
    NSMutableURLRequest *request = [_httpManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                        URLString:url
                                                                                       parameters:params
                                                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                            [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:mime];
                                                                        }
                                                                                            error:nil];
    [self sendRequest:request withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock
               withAccess:access];
}

- (void)post:(NSString *)url
             withData:(NSData *)data
           withParams:(NSDictionary *)params
          withHeaders:(NSDictionary *)headers
    withCompleteBlock:(QNCompleteBlock)completeBlock
    withProgressBlock:(QNInternalProgressBlock)progressBlock
      withCancelBlock:(QNCancelBlock)cancelBlock
           withAccess:(NSString *)access {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    if (headers) {
        [request setAllHTTPHeaderFields:headers];
    }
    [request setHTTPMethod:@"POST"];
    if (params) {
        [request setValuesForKeysWithDictionary:params];
    }
    [request setHTTPBody:data];
    QNAsyncRun(^{
        [self sendRequest:request
            withCompleteBlock:completeBlock
            withProgressBlock:progressBlock
              withCancelBlock:cancelBlock
                   withAccess:access];
    });
}

- (void)get:(NSString *)url
          withHeaders:(NSDictionary *)headers
    withCompleteBlock:(QNCompleteBlock)completeBlock {
    QNAsyncRun(^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

        NSURL *URL = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];

        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSData *s = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resp = nil;
            QNResponseInfo *info;
            if (error == nil) {
                info = [QNSessionManager buildResponseInfo:httpResponse withError:nil withDuration:0 withResponse:s withHost:@"" withIp:@""];
                if (info.isOK) {
                    resp = responseObject;
                }
            } else {
                info = [QNSessionManager buildResponseInfo:httpResponse withError:error withDuration:0 withResponse:s withHost:@"" withIp:@""];
            }

            completeBlock(info, resp);
        }];
        [dataTask resume];
    });
}

@end

#endif
