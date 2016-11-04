//
//  QNNTraceRoute.h
//  NetDiag
//
//  Created by bailong on 16/1/26.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QNNProtocols.h"
#import <Foundation/Foundation.h>

@interface QNNTraceRouteResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* ip;
@property (readonly) NSString* content;

@end

typedef void (^QNNTraceRouteCompleteHandler)(QNNTraceRouteResult*);

@interface QNNTraceRoute : NSObject <QNNStopDelegate>

+ (instancetype)start:(NSString*)host
               output:(id<QNNOutputDelegate>)output
             complete:(QNNTraceRouteCompleteHandler)complete;

+ (instancetype)start:(NSString*)host
               output:(id<QNNOutputDelegate>)output
             complete:(QNNTraceRouteCompleteHandler)complete
               maxTtl:(NSInteger)maxTtl;

@end