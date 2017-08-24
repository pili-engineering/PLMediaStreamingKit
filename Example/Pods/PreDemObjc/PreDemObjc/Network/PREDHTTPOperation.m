//
//  PREDHTTPOperation.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDHTTPOperation.h"

@implementation PREDHTTPOperation {
    NSURLRequest *_URLRequest;
    NSURLSessionDataTask *_task;
}

@synthesize data = _data;
@synthesize executing = _isExecuting;
@synthesize finished = _isFinished;


+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest {
    PREDHTTPOperation *op = [[self class] new];
    op->_URLRequest = urlRequest;
    return op;
}

#pragma mark - NSOperation overrides
- (BOOL)isAsynchronous {
    return YES;
}

- (void)cancel {
    [_task cancel];
    [super cancel];
}

- (void)start {
    if(self.isCancelled) {
        [self finish];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    _task = [[NSURLSession sharedSession] dataTaskWithRequest:_URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _response = (NSHTTPURLResponse *)response;
        if (error) {
            _error = error;
        } else {
            _data = data;
        }
        [self finish];
    }];
    [_task resume];
}

- (void) finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Public interface

- (void)setCompletion:(PREDNetworkCompletionBlock)completion {
    if(!completion) {
        [super setCompletionBlock:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [super setCompletionBlock:^{
            typeof(self) strongSelf = weakSelf;
            if(strongSelf) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!strongSelf.isCancelled) {
                        completion(strongSelf, strongSelf->_data, strongSelf->_error);
                    }
                    [strongSelf setCompletionBlock:nil];
                });
            }
        }];
    }
}

- (BOOL)isFinished {
    return _isFinished;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

@end
