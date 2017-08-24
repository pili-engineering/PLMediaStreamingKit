//
//  PREDURLProtocol.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDURLProtocol.h"
#import <HappyDNS/HappyDNS.h>
#import "PREDURLSessionSwizzler.h"
#import "PREDHTTPMonitorModel.h"
#import "PREDHTTPMonitorSender.h"

#define DNSPodsHost @"119.29.29.29"

@interface PREDURLProtocol ()
<
NSURLSessionDataDelegate
>

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) PREDHTTPMonitorModel *HTTPMonitorModel;

@end

@implementation PREDURLProtocol

@synthesize HTTPMonitorModel;

+ (void)setClient:(PREDNetworkClient *)client {
    [PREDHTTPMonitorSender setClient:client];
}

+ (void)enableHTTPDem {
    if (PREDHTTPMonitorSender.isEnabled) {
        return;
    }
    // 可拦截 [NSURLSession defaultSession] 以及 UIWebView 相关的请求
    [NSURLProtocol registerClass:self.class];
    
    // 拦截自定义生成的 NSURLSession 的请求
    if (![PREDURLSessionSwizzler isSwizzle]) {
        [PREDURLSessionSwizzler load];
    }
    
    PREDHTTPMonitorSender.enable = YES;
}

+ (void)disableHTTPDem {
    if (!PREDHTTPMonitorSender.isEnabled) {
        return;
    }
    [NSURLProtocol unregisterClass:self.class];
    if ([PREDURLSessionSwizzler isSwizzle]) {
        [PREDURLSessionSwizzler unload];
    }
    PREDHTTPMonitorSender.enable = NO;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    // SDK主动发送的数据
    if ([NSURLProtocol propertyForKey:@"PREDInternalRequest" inRequest:request] ) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if (mutableRequest.URL.path.length == 0) {
        mutableRequest.URL = [NSURL URLWithString:@"/" relativeToURL:mutableRequest.URL];
    }
    [NSURLProtocol setProperty:@YES
                        forKey:@"PREDInternalRequest"
                     inRequest:mutableRequest];
    [NSURLProtocol setProperty:mutableRequest.URL
                        forKey:@"PREDOriginalURL"
                     inRequest:mutableRequest];
    if ([request.URL.scheme isEqualToString:@"http"]) {
        NSMutableArray *resolvers = [[NSMutableArray alloc] init];
        [resolvers addObject:[QNResolver systemResolver]];
        [resolvers addObject:[[QNResolver alloc] initWithAddress:DNSPodsHost]];
        QNDnsManager *dns = [[QNDnsManager alloc] init:resolvers networkInfo:[QNNetworkInfo normal]];
        NSTimeInterval dnsStartTime = [[NSDate date] timeIntervalSince1970];
        NSURL *replacedURL = [dns queryAndReplaceWithIP:mutableRequest.URL];
        NSTimeInterval dnsEndTime = [[NSDate date] timeIntervalSince1970];
        NSError *err;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+\\.[0-9]+\\.[0-9]+" options:0 error:&err];
        NSInteger number = [regex numberOfMatchesInString:replacedURL.host options:0 range:NSMakeRange(0, [replacedURL.host length])];
        if (number == 0) {
            return mutableRequest;
        }
        [NSURLProtocol setProperty:@((dnsEndTime - dnsStartTime)*1000)
                            forKey:@"PREDDNSTime"
                         inRequest:mutableRequest];
        [NSURLProtocol setProperty:replacedURL.host
                            forKey:@"PREDHostIP"
                         inRequest:mutableRequest];
        [mutableRequest setValue:request.URL.host forHTTPHeaderField:@"Host"];
        mutableRequest.URL = replacedURL;
    }
    return mutableRequest;
}

- (void)startLoading {
    NSURLSessionConfiguration *sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue new]];
    self.task = [session dataTaskWithRequest:self.request];
    [self.task resume];
    
    HTTPMonitorModel = [[PREDHTTPMonitorModel alloc] init];
    NSURL *originURL = [NSURLProtocol propertyForKey:@"PREDOriginalURL" inRequest:self.request];
    HTTPMonitorModel.domain = originURL.host;
    HTTPMonitorModel.path = originURL.path;
    HTTPMonitorModel.method = self.request.HTTPMethod;
    HTTPMonitorModel.hostIP = [NSURLProtocol propertyForKey:@"PREDHostIP" inRequest:self.request];
    HTTPMonitorModel.startTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    HTTPMonitorModel.endTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    HTTPMonitorModel.DNSTime = [[NSURLProtocol propertyForKey:@"PREDDNSTime" inRequest:self.request] unsignedIntegerValue];
}

- (void)stopLoading {
    [self.task cancel];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
    HTTPMonitorModel.responseTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    HTTPMonitorModel.statusCode = ((NSHTTPURLResponse *)response).statusCode;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    HTTPMonitorModel.endTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    HTTPMonitorModel.dataLength += data.length;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
        HTTPMonitorModel.networkErrorCode = error.code;
        HTTPMonitorModel.networkErrorMsg = error.localizedDescription;
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
    [PREDHTTPMonitorSender addModel:HTTPMonitorModel];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
