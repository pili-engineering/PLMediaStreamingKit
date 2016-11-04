//
//  QNNHttp.h
//  NetDiag
//
//  Created by bailong on 16/2/10.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNProtocols.h"
#import <Foundation/Foundation.h>

@interface QNNHttpResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* ip;
@property (readonly) NSTimeInterval duration;
@property (readonly) NSDictionary* headers;
@property (readonly) NSData* body;

- (NSString*)description;

@end

typedef void (^QNNHttpCompleteHandler)(QNNHttpResult*);

@interface QNNHttp : NSObject <QNNStopDelegate>

/**
 *    default port is 80
 *
 *    @param host     domain or ip
 *    @param output   output logger
 *    @param complete complete callback, maybe null
 *
 *    @return QNNTcpping instance, could be stop
 */
+ (instancetype)start:(NSString*)url
               output:(id<QNNOutputDelegate>)output
             complete:(QNNHttpCompleteHandler)complete;

@end