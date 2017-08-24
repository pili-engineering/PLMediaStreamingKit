//
//  PREDHTTPMonitorSender.m
//  PreDemObjc
//
//  Created by WangSiyu on 28/03/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDHTTPMonitorSender.h"
#import "PREDGZIP.h"
#import "PREDLogger.h"
#import "PREDManagerPrivate.h"

#define PREDSendLogDefaultInterval  10
#define PREDMaxLogLenth            (1024 * 64)
#define PREDMaxLogIndex             100

#define PREDErrorDomain             @"error.sdk.predem"
#define PREDReadFileIndexKey        @"read_file_index"
#define PREDReadFilePositionKey     @"read_file_position"
#define PREDWriteFileIndexKey       @"write_file_index"
#define PREDWriteFilePosition       @"write_file_position"

static NSString * wrapString(NSString *st) {
    NSString *ret = st ? (st.length != 0 ? st : @"-") : @"-";
    return ret;
}

static BOOL enableMonitor;

@interface PREDHTTPMonitorSender ()
<
NSURLSessionDelegate
>

@property (nonatomic, strong) NSString          *logDirPath;
@property (nonatomic, strong) NSString          *indexFilePath;
@property (nonatomic, assign) unsigned int      mReadFileIndex;
@property (nonatomic, assign) unsigned int      mReadFilePosition;
@property (nonatomic, assign) unsigned int      mWriteFileIndex;
@property (nonatomic, assign) unsigned int      mWriteFilePosition;
@property (nonatomic, strong) NSTimer           *sendTimer;
@property (nonatomic, strong) NSRecursiveLock   *indexFileIOLock;
@property (nonatomic, strong) NSRecursiveLock   *logFileIOLock;
@property (nonatomic, strong) NSFileHandle      *indexFileHandle;
@property (nonatomic, assign) BOOL              isSendingData;
@property (nonatomic, strong) NSURLSession      *urlSession;
@property (nonatomic, strong) NSString          *logPathToBeRemoved;
@property (nonatomic, strong) PREDNetworkClient *client;

@end

@implementation PREDHTTPMonitorSender

+ (PREDHTTPMonitorSender *)sharedSender {
    static PREDHTTPMonitorSender *sender;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sender = [[self alloc] init];
    });
    return sender;
}

+ (void)setClient:(PREDNetworkClient *)client {
    [self sharedSender].client = client;
}

- (instancetype)init {
    if (self = [super init]) {
        _logDirPath = [NSString stringWithFormat:@"%@Presniff_SDK_Log", [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0] absoluteString] substringFromIndex:7]];
        _indexFilePath = [NSString stringWithFormat:@"%@/index.json", _logDirPath];
        _mReadFileIndex = 1;
        _mReadFilePosition = 0;
        _mWriteFileIndex = 1;
        _mWriteFilePosition = 0;
        _indexFileIOLock = [NSRecursiveLock new];
        _logFileIOLock = [NSRecursiveLock new];
        NSURLSessionConfiguration *sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration;
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return self;
}

/**
 * 上报数据结构
 ```
 {
 appName:            String  // 宿主 App 的名字。
 appBundleId:        String  // 宿主 App 的唯一标识号(包名)
 osVersion:          String  // 系统版本号
 deviceModel:        String  // 设备型号
 deviceUUID:         String  // 设备唯一识别号
 domain:             String  // 请求的 Domain Name
 path:               String  // 请求的 Path
 method:             String  // 请求使用的 HTTP 方法，如 POST 等
 hostIP:             String  // 实际发生请求的主机 IP 地址
 statusCode:         Int     // 服务器返回的 HTTP 状态码
 startTimestamp:     UInt64  // 请求开始时间戳，单位是 Unix ms
 responseTimeStamp:  UInt64  // 服务器返回 Response 的时间戳，单位是 Unix ms
 endTimestamp:       UInt64  // 请求结束时间戳，单位是 Unix ms
 DNSTime:            UInt    // 请求的 DNS 解析时间, 单位是 ms
 dataLength:         UInt    // 请求返回的 data 的总长度，单位是 byte
 networkErrorCode:   Int     // 请求发生网络错误时的错误码
 networkErrorMsg:    String  // 请求发生网络错误时的错误信息
 }
 ```
 */
+ (void)addModel:(PREDHTTPMonitorModel *)model {
    NSArray *modelArray = @[
                            @(model.platform),
                            wrapString(model.appName),
                            wrapString(model.appBundleId),
                            wrapString(model.osVersion),
                            wrapString(model.deviceModel),
                            wrapString(model.deviceUUID),
                            wrapString(model.tag),
                            wrapString(model.domain),
                            wrapString(model.path),
                            wrapString(model.method),
                            wrapString(model.hostIP),
                            @(model.statusCode),
                            @(model.startTimestamp),
                            @(model.responseTimeStamp),
                            @(model.endTimestamp),
                            @(model.DNSTime),
                            @(model.dataLength),
                            @(model.networkErrorCode),
                            wrapString(model.networkErrorMsg)
                            ];
    [[self sharedSender] writeArray:modelArray];
}

+ (void)setEnable:(BOOL)enable {
    enableMonitor = enable;
    if (enable && ![self sharedSender]->_sendTimer) {
        [self sharedSender]->_sendTimer = [NSTimer timerWithTimeInterval:PREDSendLogDefaultInterval target:[self sharedSender] selector:@selector(sendLog) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer: [self sharedSender]->_sendTimer forMode:NSRunLoopCommonModes];
    } else if (!enable && [self sharedSender]->_sendTimer) {
        [[self sharedSender]->_sendTimer invalidate];
        [self sharedSender]->_sendTimer = nil;
    }
}

+ (BOOL)isEnabled {
    return enableMonitor;
}

- (NSError *)writeArray:(NSArray *)array {
    if (!enableMonitor) {
        return nil;
    }
    __block NSString *toWrite;
    [array enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (0 == idx) {
            toWrite = [NSString stringWithFormat:@"%@", obj];
        }else if (idx == array.count - 1) {
            toWrite = [NSString stringWithFormat:@"%@\t%@\n", toWrite, obj];
        } else {
            toWrite = [NSString stringWithFormat:@"%@\t%@", toWrite, obj];
        }
    }];
    NSData *dataToWrite = [toWrite dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL isDir = NO, exist = NO;
    NSError *err;
    
    exist = [[NSFileManager defaultManager] fileExistsAtPath:_logDirPath isDirectory:&isDir];
    if (!(exist && isDir)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_logDirPath withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err) {
        PREDLogError(@"log file create error: %@", err);
        return err;
    }
    exist = [[NSFileManager defaultManager] fileExistsAtPath:_indexFilePath isDirectory:&isDir];
    if (!(exist && !isDir)) {
        [[NSFileManager defaultManager] createFileAtPath:_indexFilePath contents:nil attributes:nil];
        err = [self updateIndexFile];
        if (err) {
            return err;
        }
    }
    err = [self parseIndexFile];
    if (err) {
        return err;
    }
    err = [self writeData:dataToWrite];
    return err;
}

- (NSError *)updateIndexFile {
    NSError *err = nil;
    NSDictionary *dic = @{PREDReadFileIndexKey: @(_mReadFileIndex),
                          PREDReadFilePositionKey: @(_mReadFilePosition),
                          PREDWriteFileIndexKey: @(_mWriteFileIndex),
                          PREDWriteFilePosition: @(_mWriteFilePosition)};
    NSData *indexData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
    if (err) {
        PREDLogError(@"create json for update index file error: %@", err);
        return err;
    }
    if (!_indexFileHandle) {
        _indexFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_indexFilePath];
    }
    if (!_indexFileHandle) {
        err = [NSError errorWithDomain:PREDErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"create index file handle error for: %@", _indexFilePath]}];
        PREDLogError(@"%@", err);
        return err;
    }
    
    [_indexFileHandle seekToFileOffset:0];
    [_indexFileIOLock lock];
    [_indexFileHandle writeData:indexData];
    [_indexFileHandle truncateFileAtOffset:indexData.length];
    [_indexFileIOLock unlock];
    return nil;
}

- (NSError *)parseIndexFile {
    [_indexFileIOLock lock];
    NSData *indexData = [NSData dataWithContentsOfFile:_indexFilePath];
    NSError *err = nil;
    if (indexData != nil) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:indexData options:0 error:&err];
        if (err) {
            PREDLogError(@"error:parse data failed %@", err);
            [_indexFileIOLock unlock];
            return err;
        }
        if (!dic || ![dic respondsToSelector:@selector(objectForKey:)]) {
            PREDLogError(@"index file json is not valid dictionary object");
            [_indexFileIOLock unlock];
            return err;
        }
        _mReadFileIndex = (unsigned int)[[dic objectForKey:PREDReadFileIndexKey] unsignedIntegerValue];
        _mReadFilePosition = (unsigned int)[[dic objectForKey:PREDReadFilePositionKey] unsignedIntegerValue];
        _mWriteFileIndex = (unsigned int)[[dic objectForKey:PREDWriteFileIndexKey] unsignedIntegerValue];
        _mWriteFilePosition = (unsigned int)[[dic objectForKey:PREDWriteFilePosition] unsignedIntegerValue];
    } else {
        err = [NSError errorWithDomain:@"com.predem" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"index file not exist"}];
    }
    [_indexFileIOLock unlock];
    return err;
}

- (NSError *)writeData:(NSData *)dataToWrite {
    BOOL isDir = NO, exist = NO;
    NSError *err;
    
    if (_mWriteFilePosition + dataToWrite.length > PREDMaxLogLenth) {
        if (_mWriteFileIndex == PREDMaxLogIndex) {
            _mWriteFileIndex = 1;
        } else {
            _mWriteFileIndex ++;
        }
        _mWriteFilePosition = 0;
    }
    
    NSString *logName = [NSString stringWithFormat:@"log.%u", _mWriteFileIndex];
    NSString *logPath = [NSString stringWithFormat:@"%@/%@", _logDirPath, logName];
    exist = [[NSFileManager defaultManager] fileExistsAtPath:logPath isDirectory:&isDir];
    if (!(exist && !isDir)) {
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil];
        if (!success) {
            err = [NSError errorWithDomain:PREDErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"create http monior log file error for: %@", logPath]}];
            PREDLogError(@"%@", err);
            return err;
        }
    }
    NSFileHandle *logFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
    if (!logFileHandle) {
        err = [NSError errorWithDomain:PREDErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"create http monior log file handle error for: %@", logPath]}];
        PREDLogError(@"%@", err);
        return err;
    }
    [logFileHandle seekToFileOffset:_mWriteFilePosition];
    // 如果更新 index 发生错误就丢弃这条日志，下次再重试
    _mWriteFilePosition += dataToWrite.length;
    err = [self updateIndexFile];
    if (err) {
        _mWriteFilePosition -= dataToWrite.length;
        return err;
    }
    [_logFileIOLock lock];
    [logFileHandle writeData:dataToWrite];
    [_logFileIOLock unlock];
    return nil;
}

- (void)sendLog {
    if (!enableMonitor) {
        return;
    }
    if (_isSendingData) {
        return;
    }
    _isSendingData = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL isDir = NO, exist = NO;
        NSError *err;
        
        err = [self parseIndexFile];
        if (err) {
            _isSendingData = NO;
            return;
        }
        NSString *logFilePath = [NSString stringWithFormat:@"%@/log.%u", _logDirPath, _mReadFileIndex];
        exist = [[NSFileManager defaultManager] fileExistsAtPath:logFilePath isDirectory:&isDir];
        if (!exist || isDir) {
            PREDLogError(@"log file path not exist");
            _isSendingData = NO;
            return;
        }
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
        if (!handle) {
            PREDLogError(@"log file handle generate failed");
            _isSendingData = NO;
            return;
        }
        
        NSData *dataUncompressed;
        [handle seekToFileOffset:_mReadFilePosition];
        if (_mReadFileIndex == _mWriteFileIndex) {
            dataUncompressed = [handle readDataOfLength:(_mWriteFilePosition - _mReadFilePosition)];
            _logPathToBeRemoved = nil;
        } else {
            dataUncompressed = [handle readDataToEndOfFile];
            if (!dataUncompressed.length) {
                [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&err];
                if (err) {
                    PREDLogError(@"remove log file failed: %@", err);
                }
                // 删除失败依然需要将读取的位置切换到下个文件，不管之前的文件了
                if (_mReadFileIndex == PREDMaxLogIndex) {
                    _mReadFileIndex = 1;
                } else {
                    _mReadFileIndex ++;
                }
                _mReadFilePosition = 0;
                [self updateIndexFile];
                _isSendingData = NO;
                return;
            }
            _logPathToBeRemoved = logFilePath;
        }
        
        if (!dataUncompressed || !dataUncompressed.length) {
            _isSendingData = NO;
            return;
        }
        
        NSData *dataToSend = [dataUncompressed gzippedData];
        if (!dataToSend || !dataToSend.length) {
            PREDLogError(@"compressed data is empty");
            _isSendingData = NO;
            return;
        }
        
        NSDictionary *headers = @{
                                  @"Content-Type": @"application/x-gzip",
                                  @"Content-Encoding": @"gzip",
                                  };
        [_client postPath:@"http-stats/i" data:dataToSend headers:headers completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
            if (error || operation.response.statusCode >= 400) {
                PREDLogError(@"log send failure, statusCode: %@, error: %@", [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode], err);
            } else {
                if (_logPathToBeRemoved) {
                    [[NSFileManager defaultManager] removeItemAtPath:_logPathToBeRemoved error:&error];
                    if (error) {
                        PREDLogError(@"delete log file failed: %@", error);
                    }
                    if (_mReadFileIndex == PREDMaxLogIndex) {
                        _mReadFileIndex = 1;
                    } else {
                        _mReadFileIndex ++;
                    }
                    _mReadFilePosition = 0;
                } else {
                    _mReadFilePosition = _mWriteFilePosition;
                }
            }
            [self updateIndexFile];
            _isSendingData = NO;
        }];
    });
}


@end
