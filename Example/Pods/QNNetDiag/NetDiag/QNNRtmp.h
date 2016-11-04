//
//  QNNRtmp.h
//  NetDiag
//
//  Created by bailong on 16/1/26.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNProtocols.h"
#import <Foundation/Foundation.h>

extern const int kQNNRtmpServerVersionError;
extern const int kQNNRtmpServerSignatureError;
extern const int kQNNRtmpServerTimeError;

@interface QNNRtmpHandshakeResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSTimeInterval maxTime;
@property (readonly) NSTimeInterval minTime;
@property (readonly) NSTimeInterval avgTime;
@property (readonly) NSInteger count;

- (NSString*)description;

@end

typedef void (^QNNRtmpHandshakeCompleteHandler)(QNNRtmpHandshakeResult*);

@interface QNNRtmpHandshake : NSObject <QNNStopDelegate>

/**
 *    default port is 1935
 *
 *    @param host     domain or ip
 *    @param output   output logger
 *    @param complete complete callback, maybe null
 *
 *    @return QNNTcpping instance, could be stop
 */
+ (instancetype)start:(NSString*)host
               output:(id<QNNOutputDelegate>)output
             complete:(QNNRtmpHandshakeCompleteHandler)complete;

+ (instancetype)start:(NSString*)host
                 port:(NSUInteger)port
                count:(NSInteger)count
               output:(id<QNNOutputDelegate>)output
             complete:(QNNRtmpHandshakeCompleteHandler)complete;

@end