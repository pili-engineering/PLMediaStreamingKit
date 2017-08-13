//
//  QNUploader.h
//  QiniuSDK
//
//  Created by bailong on 14-9-28.
//  Copyright (c) 2014年 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "QNALAssetFile.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#import "QNPHAssetFile.h"
#import <Photos/Photos.h>
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90100
#import "QNPHAssetResource.h"
#endif

#else
#import <CoreServices/CoreServices.h>
#endif

#import "QNAsyncRun.h"
#import "QNConfiguration.h"
#import "QNCrc32.h"
#import "QNFile.h"
#import "QNFormUpload.h"
#import "QNResponseInfo.h"
#import "QNResumeUpload.h"
#import "QNSessionManager.h"
#import "QNSystem.h"
#import "QNUpToken.h"
#import "QNUploadManager.h"
#import "QNUploadOption+Private.h"

@interface QNUploadManager ()
@property (nonatomic) id<QNHttpDelegate> httpManager;
@property (nonatomic) QNConfiguration *config;
@end

@implementation QNUploadManager

- (instancetype)init {
    return [self initWithConfiguration:nil];
}

- (instancetype)initWithRecorder:(id<QNRecorderDelegate>)recorder {
    return [self initWithRecorder:recorder recorderKeyGenerator:nil];
}

- (instancetype)initWithRecorder:(id<QNRecorderDelegate>)recorder
            recorderKeyGenerator:(QNRecorderKeyGenerator)recorderKeyGenerator {
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.recorder = recorder;
        builder.recorderKeyGen = recorderKeyGenerator;
    }];
    return [self initWithConfiguration:config];
}

- (instancetype)initWithConfiguration:(QNConfiguration *)config {
    if (self = [super init]) {
        if (config == nil) {
            config = [QNConfiguration build:^(QNConfigurationBuilder *builder){
            }];
        }
        _config = config;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
        _httpManager = [[QNSessionManager alloc] initWithProxy:config.proxy timeout:config.timeoutInterval urlConverter:config.converter dns:config.dns];
#endif
    }
    return self;
}

+ (instancetype)sharedInstanceWithConfiguration:(QNConfiguration *)config {
    static QNUploadManager *sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithConfiguration:config];
    });

    return sharedInstance;
}

+ (BOOL)checkAndNotifyError:(NSString *)key
                      token:(NSString *)token
                      input:(NSObject *)input
                   complete:(QNUpCompletionHandler)completionHandler {
    NSString *desc = nil;
    if (completionHandler == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"no completionHandler"
                                     userInfo:nil];
        return YES;
    }
    if (input == nil) {
        desc = @"no input data";
    } else if (token == nil || [token isEqual:[NSNull null]] || [token isEqualToString:@""]) {
        desc = @"no token";
    }
    if (desc != nil) {
        QNAsyncRunInMain(^{
            completionHandler([QNResponseInfo responseInfoWithInvalidArgument:desc], key, nil);
        });
        return YES;
    }
    return NO;
}

- (void)putData:(NSData *)data
            key:(NSString *)key
          token:(NSString *)token
       complete:(QNUpCompletionHandler)completionHandler
         option:(QNUploadOption *)option {
    if ([QNUploadManager checkAndNotifyError:key token:token input:data complete:completionHandler]) {
        return;
    }

    QNUpToken *t = [QNUpToken parse:token];
    if (t == nil) {
        QNAsyncRunInMain(^{
            completionHandler([QNResponseInfo responseInfoWithInvalidToken:@"invalid token"], key, nil);
        });
        return;
    }

    [_config.zone preQuery:t on:^(int code) {
        if (code != 0) {
            QNAsyncRunInMain(^{
                completionHandler([QNResponseInfo responseInfoWithInvalidToken:@"get zone failed"], key, nil);
            });
            return;
        }
        if ([data length] == 0) {
            QNAsyncRunInMain(^{
                completionHandler([QNResponseInfo responseInfoOfZeroData:nil], key, nil);
            });
            return;
        }
        QNUpCompletionHandler complete = ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            QNAsyncRunInMain(^{
                completionHandler(info, key, resp);
            });
        };
        QNFormUpload *up = [[QNFormUpload alloc]
                     initWithData:data
                          withKey:key
                        withToken:t
            withCompletionHandler:complete
                       withOption:option
                  withHttpManager:_httpManager
                withConfiguration:_config];
        QNAsyncRun(^{
            [up put];
        });
    }];
}

- (void)putFileInternal:(id<QNFileDelegate>)file
                    key:(NSString *)key
                  token:(NSString *)token
               complete:(QNUpCompletionHandler)completionHandler
                 option:(QNUploadOption *)option {
    @autoreleasepool {
        QNUpToken *t = [QNUpToken parse:token];
        if (t == nil) {
            QNAsyncRunInMain(^{
                completionHandler([QNResponseInfo responseInfoWithInvalidToken:@"invalid token"], key, nil);
            });
            return;
        }

        [_config.zone preQuery:t on:^(int code) {
            if (code != 0) {
                QNAsyncRunInMain(^{
                    completionHandler([QNResponseInfo responseInfoWithInvalidToken:@"get zone failed"], key, nil);
                });
                return;
            }
            QNUpCompletionHandler complete = ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                [file close];
                QNAsyncRunInMain(^{
                    completionHandler(info, key, resp);
                });
            };

            if ([file size] <= _config.putThreshold) {
                NSData *data = [file readAll];
                [self putData:data key:key token:token complete:complete option:option];
                return;
            }

            NSString *recorderKey = key;
            if (_config.recorder != nil && _config.recorderKeyGen != nil) {
                recorderKey = _config.recorderKeyGen(key, [file path]);
            }

            NSLog(@"recorder %@", _config.recorder);

            QNResumeUpload *up = [[QNResumeUpload alloc]
                         initWithFile:file
                              withKey:key
                            withToken:t
                withCompletionHandler:complete
                           withOption:option
                         withRecorder:_config.recorder
                      withRecorderKey:recorderKey
                      withHttpManager:_httpManager
                    withConfiguration:_config];
            QNAsyncRun(^{
                [up run];
            });
        }];
    }
}

- (void)putFile:(NSString *)filePath
            key:(NSString *)key
          token:(NSString *)token
       complete:(QNUpCompletionHandler)completionHandler
         option:(QNUploadOption *)option {
    if ([QNUploadManager checkAndNotifyError:key token:token input:filePath complete:completionHandler]) {
        return;
    }

    @autoreleasepool {
        NSError *error = nil;
        __block QNFile *file = [[QNFile alloc] init:filePath error:&error];
        if (error) {
            QNAsyncRunInMain(^{
                QNResponseInfo *info = [QNResponseInfo responseInfoWithFileError:error];
                completionHandler(info, key, nil);
            });
            return;
        }
        [self putFileInternal:file key:key token:token complete:completionHandler option:option];
    }
}

- (void)putALAsset:(ALAsset *)asset
               key:(NSString *)key
             token:(NSString *)token
          complete:(QNUpCompletionHandler)completionHandler
            option:(QNUploadOption *)option {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    if ([QNUploadManager checkAndNotifyError:key token:token input:asset complete:completionHandler]) {
        return;
    }

    @autoreleasepool {
        NSError *error = nil;
        __block QNALAssetFile *file = [[QNALAssetFile alloc] init:asset error:&error];
        if (error) {
            QNAsyncRunInMain(^{
                QNResponseInfo *info = [QNResponseInfo responseInfoWithFileError:error];
                completionHandler(info, key, nil);
            });
            return;
        }
        [self putFileInternal:file key:key token:token complete:completionHandler option:option];
    }
#endif
}

- (void)putPHAsset:(PHAsset *)asset
               key:(NSString *)key
             token:(NSString *)token
          complete:(QNUpCompletionHandler)completionHandler
            option:(QNUploadOption *)option {
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
    if ([QNUploadManager checkAndNotifyError:key token:token input:asset complete:completionHandler]) {
        return;
    }

    @autoreleasepool {
        NSError *error = nil;
        __block QNPHAssetFile *file = [[QNPHAssetFile alloc] init:asset error:&error];
        if (error) {
            QNAsyncRunInMain(^{
                QNResponseInfo *info = [QNResponseInfo responseInfoWithFileError:error];
                completionHandler(info, key, nil);
            });
            return;
        }
        [self putFileInternal:file key:key token:token complete:completionHandler option:option];
    }
#endif
}

- (void)putPHAssetResource:(PHAssetResource *)assetResource
                       key:(NSString *)key
                     token:(NSString *)token
                  complete:(QNUpCompletionHandler)completionHandler
                    option:(QNUploadOption *)option {
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90100)
    if ([QNUploadManager checkAndNotifyError:key token:token input:assetResource complete:completionHandler]) {
        return;
    }
    @autoreleasepool {
        NSError *error = nil;
        __block QNPHAssetResource *file = [[QNPHAssetResource alloc] init:assetResource error:&error];
        if (error) {
            QNAsyncRunInMain(^{
                QNResponseInfo *info = [QNResponseInfo responseInfoWithFileError:error];
                completionHandler(info, key, nil);
            });
            return;
        }
        [self putFileInternal:file key:key token:token complete:completionHandler option:option];
    }
#endif
}

@end
