//
//  QNNNslookup.h
//  NetDiag
//
//  Created by bailong on 16/2/2.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNProtocols.h"
#import <Foundation/Foundation.h>

/**
 *    A 记录
 */
extern const int kQNNTypeA;

/**
 *  Cname 记录
 */
extern const int kQNNTypeCname;

@interface QNNRecord : NSObject
@property (nonatomic, readonly) NSString *value;
@property (readonly) int ttl;
@property (readonly) int type;

- (instancetype)init:(NSString *)value
                 ttl:(int)ttl
                type:(int)type;

- (NSString *)description;

@end

typedef void (^QNNNslookupCompleteHandler)(NSArray *);

@interface QNNNslookup : NSObject <QNNStopDelegate>

+ (instancetype)start:(NSString *)domain
               output:(id<QNNOutputDelegate>)output
             complete:(QNNNslookupCompleteHandler)complete;

+ (instancetype)start:(NSString *)domain
               server:(NSString *)dnsServer
               output:(id<QNNOutputDelegate>)output
             complete:(QNNNslookupCompleteHandler)complete;

@end