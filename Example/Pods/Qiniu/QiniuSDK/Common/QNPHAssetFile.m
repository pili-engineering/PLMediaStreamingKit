//
//  QNPHAssetFile.m
//  Pods
//
//  Created by   何舒 on 15/10/21.
//
//

#import "QNPHAssetFile.h"

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "QNResponseInfo.h"

@interface QNPHAssetFile ()

@property (nonatomic) PHAsset *phAsset;

@property (readonly) int64_t fileSize;

@property (readonly) int64_t fileModifyTime;

@property (nonatomic, strong) NSData *assetData;

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, readonly) NSString *filepath;

@property (nonatomic) NSFileHandle *file;

@end

@implementation QNPHAssetFile

- (instancetype)init:(PHAsset *)phAsset error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        NSDate *createTime = phAsset.creationDate;
        int64_t t = 0;
        if (createTime != nil) {
            t = [createTime timeIntervalSince1970];
        }
        _fileModifyTime = t;
        _phAsset = phAsset;
        _filepath = [self getInfo];
        if (PHAssetMediaTypeVideo == self.phAsset.mediaType) {
            NSError *error2 = nil;
            NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:_filepath error:&error2];
            if (error2 != nil) {
                if (error != nil) {
                    *error = error2;
                }
                return self;
            }
            _fileSize = [fileAttr fileSize];
            NSFileHandle *f = nil;
            NSData *d = nil;
            if (_fileSize > 16 * 1024 * 1024) {
                f = [NSFileHandle fileHandleForReadingAtPath:_filepath];
                if (f == nil) {
                    if (error != nil) {
                        *error = [[NSError alloc] initWithDomain:_filepath code:kQNFileError userInfo:nil];
                    }
                    return self;
                }
            } else {
                d = [NSData dataWithContentsOfFile:_filepath options:NSDataReadingMappedIfSafe error:&error2];
                if (error2 != nil) {
                    if (error != nil) {
                        *error = error2;
                    }
                    return self;
                }
            }
            _file = f;
            _assetData = d;
        }
    }
    return self;
}

- (NSData *)read:(long)offset size:(long)size {
    if (_assetData != nil) {
        return [_assetData subdataWithRange:NSMakeRange(offset, (unsigned int)size)];
    }
    [_file seekToFileOffset:offset];
    return [_file readDataOfLength:size];
}

- (NSData *)readAll {
    return [self read:0 size:(long)_fileSize];
}

- (void)close {
    if (PHAssetMediaTypeVideo == self.phAsset.mediaType) {
        if (_file != nil) {
            [_file closeFile];
        }
        [[NSFileManager defaultManager] removeItemAtPath:_filepath error:nil];
    }
}

- (NSString *)path {
    return _filepath;
}

- (int64_t)modifyTime {
    return _fileModifyTime;
}

- (int64_t)size {
    return _fileSize;
}

- (NSString *)getInfo {
    __block NSString *filePath = nil;
    if (PHAssetMediaTypeImage == self.phAsset.mediaType) {
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        //不支持icloud上传
        options.networkAccessAllowed = NO;
        options.synchronous = YES;

        [[PHImageManager defaultManager] requestImageDataForAsset:self.phAsset
                                                          options:options
                                                    resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                        _assetData = imageData;
                                                        _fileSize = imageData.length;
                                                        _assetURL = [NSURL URLWithString:self.phAsset.localIdentifier];
                                                        filePath = _assetURL.path;
                                                    }];
    } else if (PHAssetMediaTypeVideo == self.phAsset.mediaType) {
        NSArray *assetResources = [PHAssetResource assetResourcesForAsset:self.phAsset];
        PHAssetResource *resource;
        for (PHAssetResource *assetRes in assetResources) {
            if (assetRes.type == PHAssetResourceTypePairedVideo || assetRes.type == PHAssetResourceTypeVideo) {
                resource = assetRes;
            }
        }
        NSString *fileName = @"tempAssetVideo.mov";
        if (resource.originalFilename) {
            fileName = resource.originalFilename;
        }
        PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
        //不支持icloud上传
        options.networkAccessAllowed = NO;

        NSString *PATH_VIDEO_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_VIDEO_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:PATH_VIDEO_FILE] options:options completionHandler:^(NSError *_Nullable error) {
            if (error) {
                filePath = nil;
            } else {
                filePath = PATH_VIDEO_FILE;
            }
        }];
    }
    return filePath;
}

@end
#endif
