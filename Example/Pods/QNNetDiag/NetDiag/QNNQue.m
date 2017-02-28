//
//  QNNQue.m
//  NetDiag
//
//  Created by BaiLong on 2016/12/7.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QNNQue.h"

@interface QNNQue ()

+ (instancetype)sharedInstance;

@property (nonatomic) dispatch_queue_t que;

@end

@implementation QNNQue

+ (instancetype)sharedInstance {
    static QNNQue *sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}
- (instancetype)init {
    if (self = [super init]) {
        _que = dispatch_queue_create("qnn_que_serial", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (void)async_run_serial:(dispatch_block_t)block {
    dispatch_async([QNNQue sharedInstance].que, ^{
        block();
    });
}

+ (void)async_run_main:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
