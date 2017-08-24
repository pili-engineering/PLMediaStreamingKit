//
//  QNPHAssetResource.m
//  QiniuSDK
//
//  Created by   何舒 on 16/2/14.
//  Copyright © 2016年 Qiniu. All rights reserved.
//

#import "QNPHAssetResource.h"
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90100)
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

enum {
    kAMASSETMETADATA_PENDINGREADS = 1,
    kAMASSETMETADATA_ALLFINISHED = 0
};

#import "QNResponseInfo.h"

@interface QNPHAssetResource ()

    {
    BOOL _hasGotInfo;
}

@property (nonatomic) PHAsset *phAsset;

@property (nonatomic) PHLivePhoto *phLivePhoto;

@property (nonatomic) PHAssetResource *phAssetResource;

@property (readonly) int64_t fileSize;

@property (readonly) int64_t fileModifyTime;

@property (nonatomic, strong) NSData *assetData;

@property (nonatomic, strong) NSURL *assetURL;

@end

@implementation QNPHAssetResource
- (instancetype)init:(PHAssetResource *)phAssetResource
               error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        PHAsset *phasset = [PHAsset fetchAssetsWithBurstIdentifier:self.phAssetResource.assetLocalIdentifier options:nil][0];
        NSDate *createTime = phasset.creationDate;
        int64_t t = 0;
        if (createTime != nil) {
            t = [createTime timeIntervalSince1970];
        }
        _fileModifyTime = t;
        _phAssetResource = phAssetResource;
        [self getInfo];
    }
    return self;
}

- (NSData *)read:(long)offset size:(long)size {
    NSRange subRange = NSMakeRange(offset, size);
    if (!self.assetData) {
        self.assetData = [self fetchDataFromAsset:self.phAssetResource];
    }
    NSData *subData = [self.assetData subdataWithRange:subRange];

    return subData;
}

- (NSData *)readAll {
    return [self read:0 size:(long)_fileSize];
}

- (void)close {
}

- (NSString *)path {
    return self.assetURL.path;
}

- (int64_t)modifyTime {
    return _fileModifyTime;
}

- (int64_t)size {
    return _fileSize;
}

- (void)getInfo {
    if (!_hasGotInfo) {
        _hasGotInfo = YES;
        NSConditionLock *assetReadLock = [[NSConditionLock alloc] initWithCondition:kAMASSETMETADATA_PENDINGREADS];

        NSString *pathToWrite = [NSTemporaryDirectory() stringByAppendingString:self.phAssetResource.originalFilename];
        NSURL *localpath = [NSURL fileURLWithPath:pathToWrite];
        PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
        options.networkAccessAllowed = YES;
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:self.phAssetResource toFile:localpath options:options completionHandler:^(NSError *_Nullable error) {
            if (error == nil) {
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:localpath options:nil];
                NSNumber *fileSize = nil;
                [urlAsset.URL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
                _fileSize = [fileSize unsignedLongLongValue];
                _assetURL = urlAsset.URL;
                self.assetData = [NSData dataWithData:[NSData dataWithContentsOfURL:urlAsset.URL]];
            } else {
                NSLog(@"%@", error);
            }

            BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:pathToWrite];
            if (!blHave) {
                NSLog(@"no  have");
                return;
            } else {
                NSLog(@" have");
                BOOL blDele = [[NSFileManager defaultManager] removeItemAtPath:pathToWrite error:nil];
                if (blDele) {
                    NSLog(@"dele success");
                } else {
                    NSLog(@"dele fail");
                }
            }
            [assetReadLock lock];
            [assetReadLock unlockWithCondition:kAMASSETMETADATA_ALLFINISHED];
        }];

        [assetReadLock lockWhenCondition:kAMASSETMETADATA_ALLFINISHED];
        [assetReadLock unlock];
        assetReadLock = nil;
    }
}

- (NSData *)fetchDataFromAsset:(PHAssetResource *)videoResource {
    __block NSData *tmpData = [NSData data];

    NSConditionLock *assetReadLock = [[NSConditionLock alloc] initWithCondition:kAMASSETMETADATA_PENDINGREADS];

    NSString *pathToWrite = [NSTemporaryDirectory() stringByAppendingString:videoResource.originalFilename];
    NSURL *localpath = [NSURL fileURLWithPath:pathToWrite];
    PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
    options.networkAccessAllowed = YES;
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:videoResource toFile:localpath options:options completionHandler:^(NSError *_Nullable error) {
        if (error == nil) {
            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:localpath options:nil];
            NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL];
            tmpData = [NSData dataWithData:videoData];
        } else {
            NSLog(@"%@", error);
        }
        BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:pathToWrite];
        if (!blHave) {
            NSLog(@"no  have");
            return;
        } else {
            NSLog(@" have");
            BOOL blDele = [[NSFileManager defaultManager] removeItemAtPath:pathToWrite error:nil];
            if (blDele) {
                NSLog(@"dele success");
            } else {
                NSLog(@"dele fail");
            }
        }
        [assetReadLock lock];
        [assetReadLock unlockWithCondition:kAMASSETMETADATA_ALLFINISHED];
    }];

    [assetReadLock lockWhenCondition:kAMASSETMETADATA_ALLFINISHED];
    [assetReadLock unlock];
    assetReadLock = nil;

    return tmpData;
}

@end
#endif
