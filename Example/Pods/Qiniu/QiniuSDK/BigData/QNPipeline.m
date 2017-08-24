//
//  QNPipeline.m
//  QiniuSDK
//
//  Created by BaiLong on 2017/7/25.
//  Copyright © 2017年 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QNSessionManager.h"

#import "QNPipeline.h"

@implementation QNPipelineConfig

- (instancetype)init {
    return [self initWithHost:@"https://pipeline.qiniu.com"];
}

- (instancetype)initWithHost:(NSString*)host {
    if (self = [super init]) {
        _host = host;
        _timeoutInterval = 10;
    }
    return self;
}

@end

@interface QNPipeline ()

@property (nonatomic) id<QNHttpDelegate> httpManager;
@property (nonatomic) QNPipelineConfig* config;

+ (NSDateFormatter*)dateFormatter;

@end

static NSString* buildString(NSObject* obj) {
    NSString* v;
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumber* num = (NSNumber*)obj;
        if (num == (void*)kCFBooleanFalse) {
            v = @"false";
        } else if (num == (void*)kCFBooleanTrue) {
            v = @"true";
        } else if (!strcmp(num.objCType, @encode(BOOL))) {
            if ([num intValue] == 0) {
                v = @"false";
            } else {
                v = @"true";
            }
        } else {
            v = num.stringValue;
        }
    } else if ([obj isKindOfClass:[NSString class]]) {
        v = (NSString*)obj;
        v = [v stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        v = [v stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    } else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSSet class]]) {
        v = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    } else if ([obj isKindOfClass:[NSDate class]]) {
        v = [[QNPipeline dateFormatter] stringFromDate:(NSDate*)obj];
    } else {
        v = [obj description];
    }
    return v;
}

static void formatPoint(NSDictionary* event, NSMutableString* buffer) {
    [event enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSObject* obj, BOOL* stop) {
        if (obj == nil || [obj isEqual:[NSNull null]]) {
            return;
        }
        [buffer appendString:key];
        [buffer appendString:@"="];
        [buffer appendString:buildString(obj)];
        [buffer appendString:@"\t"];
    }];
    NSRange range = NSMakeRange(buffer.length - 1, 1);
    [buffer replaceCharactersInRange:range withString:@"\n"];
}

static NSMutableString* formatPoints(NSArray<NSDictionary*>* events) {
    NSMutableString* str = [NSMutableString new];
    [events enumerateObjectsUsingBlock:^(NSDictionary* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        formatPoint(obj, str);
    }];
    return str;
}

@implementation QNPipeline

- (instancetype)init:(QNPipelineConfig*)config {
    if (self = [super init]) {
        if (config == nil) {
            config = [QNPipelineConfig new];
        }
        _config = config;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
        _httpManager = [[QNSessionManager alloc] initWithProxy:nil timeout:config.timeoutInterval urlConverter:nil dns:nil];
#endif
    }
    return self;
}

- (void)pumpRepo:(NSString*)repo
           event:(NSDictionary*)data
           token:(NSString*)token
         handler:(QNPipelineCompletionHandler)handler {
    NSMutableString* str = [NSMutableString new];
    formatPoint(data, str);
    [self pumpRepo:repo string:str token:token handler:handler];
}

- (void)pumpRepo:(NSString*)repo
          events:(NSArray<NSDictionary*>*)data
           token:(NSString*)token
         handler:(QNPipelineCompletionHandler)handler {
    NSMutableString* str = formatPoints(data);
    [self pumpRepo:repo string:str token:token handler:handler];
}

- (NSString*)url:(NSString*)repo {
    return [NSString stringWithFormat:@"%@/v2/repos/%@/data", _config.host, repo];
}

- (void)pumpRepo:(NSString*)repo
          string:(NSString*)str
           token:(NSString*)token
         handler:(QNPipelineCompletionHandler)handler {
    NSDictionary* headers = @{ @"Authorization" : token,
                               @"Content-Type" : @"text/plain" };
    [_httpManager post:[self url:repo] withData:[str dataUsingEncoding:NSUTF8StringEncoding] withParams:nil withHeaders:headers withCompleteBlock:^(QNResponseInfo* info, NSDictionary* resp) {
        handler(info);
    }
        withProgressBlock:nil
          withCancelBlock:nil
               withAccess:nil];
}

+ (NSDateFormatter*)dateFormatter {
    static NSDateFormatter* formatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    });

    return formatter;
}

@end
