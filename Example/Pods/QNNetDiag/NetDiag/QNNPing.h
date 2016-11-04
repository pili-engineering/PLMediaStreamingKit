//
//  QNNPing.h
//  NetDiag
//
//  Created by bailong on 15/12/30.
//  Copyright © 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNProtocols.h"
#import <Foundation/Foundation.h>

extern const int kQNNInvalidPingResponse;

@interface QNNPingResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* ip;
@property (readonly) NSUInteger size;
@property (readonly) NSTimeInterval maxRtt;
@property (readonly) NSTimeInterval minRtt;
@property (readonly) NSTimeInterval avgRtt;
@property (readonly) NSInteger loss;
@property (readonly) NSInteger count;
@property (readonly) NSTimeInterval totalTime;
@property (readonly) NSTimeInterval stddev;

- (NSString*)description;

@end

typedef void (^QNNPingCompleteHandler)(QNNPingResult*);

@interface QNNPing : NSObject <QNNStopDelegate>

+ (instancetype)start:(NSString*)host
                 size:(NSUInteger)size
               output:(id<QNNOutputDelegate>)output
             complete:(QNNPingCompleteHandler)complete;

+ (instancetype)start:(NSString*)host
                 size:(NSUInteger)size
               output:(id<QNNOutputDelegate>)output
             complete:(QNNPingCompleteHandler)complete
             interval:(NSInteger)interval
                count:(NSInteger)count;

@end
