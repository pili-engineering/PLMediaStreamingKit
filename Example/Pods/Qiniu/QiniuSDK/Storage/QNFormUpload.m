//
//  QNFormUpload.m
//  QiniuSDK
//
//  Created by bailong on 15/1/4.
//  Copyright (c) 2015年 Qiniu. All rights reserved.
//

#import "QNFormUpload.h"
#import "QNConfiguration.h"
#import "QNCrc32.h"
#import "QNRecorderDelegate.h"
#import "QNResponseInfo.h"
#import "QNUploadManager.h"
#import "QNUploadOption+Private.h"
#import "QNUrlSafeBase64.h"

@interface QNFormUpload ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) id<QNHttpDelegate> httpManager;
@property (nonatomic) int retryTimes;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) QNUpToken *token;
@property (nonatomic, strong) QNUploadOption *option;
@property (nonatomic, strong) QNUpCompletionHandler complete;
@property (nonatomic, strong) QNConfiguration *config;
@property (nonatomic) float previousPercent;

@property (nonatomic, strong) NSString *access; //AK

@end

@implementation QNFormUpload

- (instancetype)initWithData:(NSData *)data
                     withKey:(NSString *)key
                   withToken:(QNUpToken *)token
       withCompletionHandler:(QNUpCompletionHandler)block
                  withOption:(QNUploadOption *)option
             withHttpManager:(id<QNHttpDelegate>)http
           withConfiguration:(QNConfiguration *)config {
    if (self = [super init]) {
        _data = data;
        _key = key;
        _token = token;
        _option = option != nil ? option : [QNUploadOption defaultOptions];
        _complete = block;
        _httpManager = http;
        _config = config;
        _previousPercent = 0;
        _access = token.access;
    }
    return self;
}

- (void)put {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *fileName = _key;
    if (_key) {
        parameters[@"key"] = _key;
    } else {
        fileName = @"?";
    }

    parameters[@"token"] = _token.token;

    [parameters addEntriesFromDictionary:_option.params];

    if (_option.checkCrc) {
        parameters[@"crc32"] = [NSString stringWithFormat:@"%u", (unsigned int)[QNCrc32 data:_data]];
    }

    QNInternalProgressBlock p = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float percent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        if (percent > 0.95) {
            percent = 0.95;
        }
        if (percent > _previousPercent) {
            _previousPercent = percent;
        } else {
            percent = _previousPercent;
        }
        _option.progressHandler(_key, percent);
    };

    QNCompleteBlock complete = ^(QNResponseInfo *info, NSDictionary *resp) {
        if (info.isOK) {
            _option.progressHandler(_key, 1.0);
        }
        if (info.isOK || !info.couldRetry) {
            _complete(info, _key, resp);
            return;
        }
        if (_option.cancellationSignal()) {
            _complete([QNResponseInfo cancel], _key, nil);
            return;
        }
        NSString *nextHost = [_config.zone up:_token].address;
        if (info.isConnectionBroken || info.needSwitchServer) {
            nextHost = [_config.zone upBackup:_token].address;
        }

        QNCompleteBlock retriedComplete = ^(QNResponseInfo *info, NSDictionary *resp) {
            if (info.isOK) {
                _option.progressHandler(_key, 1.0);
            }
            _complete(info, _key, resp);
        };

        [_httpManager multipartPost:nextHost
                           withData:_data
                         withParams:parameters
                       withFileName:fileName
                       withMimeType:_option.mimeType
                  withCompleteBlock:retriedComplete
                  withProgressBlock:p
                    withCancelBlock:_option.cancellationSignal
                         withAccess:_access];
    };

    [_httpManager multipartPost:[_config.zone up:_token].address
                       withData:_data
                     withParams:parameters
                   withFileName:fileName
                   withMimeType:_option.mimeType
              withCompleteBlock:complete
              withProgressBlock:p
                withCancelBlock:_option.cancellationSignal
                     withAccess:_access];
}

@end
