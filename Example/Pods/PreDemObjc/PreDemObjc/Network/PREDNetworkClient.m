//
//  PREDNetworkClient.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDNetworkClient.h"
#import "PREDLogger.h"

#define PREDNetMaxRetryTimes    5
#define PREDNetRetryInterval    30

@implementation PREDNetworkClient

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    if ( self ) {
        NSParameterAssert(baseURL);
        _baseURL = baseURL;
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)dealloc {
    [self cancelOperationsWithPath:nil method:nil];
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)params completion:(PREDNetworkCompletionBlock)completion {
    [self getPath:path parameters:params completion:completion retried:0];
}

- (void)postPath:(NSString *)path parameters:(id)params completion:(PREDNetworkCompletionBlock)completion {
    [self postPath:path parameters:params completion:completion retried:0];
}

- (void) postPath:(NSString*) path
             data:(NSData *) data
          headers:(NSDictionary *)headers
       completion:(PREDNetworkCompletionBlock) completion {
    [self postPath:path data:data headers:headers completion:completion retried:0];
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)params completion:(PREDNetworkCompletionBlock)completion retried:(NSInteger)retried {
    NSError *err;
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:params error:&err];
    if (err) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, nil, err);
        });
        return;
    }
    __weak typeof(self) wSelf = self;
    PREDHTTPOperation *op = [self operationWithURLRequest:request
                                               completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
                                                   if ((error || operation.response.statusCode >= 400) && retried < PREDNetMaxRetryTimes) {
                                                       PREDLogWarning(@"%@ request failed for: %@ statusCode: %ld", request.URL.absoluteString, error, (long)operation.response.statusCode);
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PREDNetRetryInterval * NSEC_PER_SEC)), dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_BACKGROUND), ^{
                                                           __strong typeof(wSelf) strongSelf = wSelf;
                                                           [strongSelf getPath:path parameters:params completion:completion retried:retried + 1];
                                                       });
                                                   } else {
                                                       PREDLogDebug(@"request for url %@ succeeded, response data: %@", request.URL.absoluteString, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                                                       completion(operation, data, error);
                                                   }
                                               }];
    [self enqeueHTTPOperation:op];
}

- (void)postPath:(NSString *)path parameters:(id)params completion:(PREDNetworkCompletionBlock)completion retried:(NSInteger)retried {
    NSError *err;
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:params error:&err];
    if (err) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, nil, err);
        });
        return;
    }
    __weak typeof(self) wSelf = self;
    PREDHTTPOperation *op = [self operationWithURLRequest:request
                                               completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
                                                   if (error && retried < PREDNetMaxRetryTimes) {
                                                       PREDLogWarning(@"%@ request failed for: %@ statusCode: %ld", request.URL.absoluteString, error, (long)operation.response.statusCode);
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PREDNetRetryInterval * NSEC_PER_SEC)), dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_BACKGROUND), ^{
                                                           __strong typeof(wSelf) strongSelf = wSelf;
                                                           [strongSelf postPath:path parameters:params completion:completion retried:retried + 1];
                                                       });
                                                   } else {
                                                       PREDLogDebug(@"request for url %@ succeeded, response data: %@", request.URL.absoluteString, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);                                                       completion(operation, data, error);
                                                   }
                                               }];
    [self enqeueHTTPOperation:op];
}

- (void) postPath:(NSString*) path
             data:(NSData *) data
          headers:(NSDictionary *)headers
       completion:(PREDNetworkCompletionBlock) completion
          retried:(NSInteger)retried {
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@", _baseURL, path];
    NSURL *endpoint = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    request.HTTPMethod = @"POST";
    [NSURLProtocol setProperty:@YES
                        forKey:@"PREDInternalRequest"
                     inRequest:request];
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSAssert([key isKindOfClass:[NSString class]], @"headers can only be string-string pairs");
            NSAssert([obj isKindOfClass:[NSString class]], @"headers can only be string-string pairs");
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    [request setHTTPBody:data];
    __weak typeof(self) wSelf = self;
    PREDHTTPOperation *op = [self operationWithURLRequest:request
                                               completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
                                                   if (error && retried < PREDNetMaxRetryTimes) {
                                                       PREDLogWarning(@"%@ request failed for: %@ statusCode: %ld", request.URL.absoluteString, error, (long)operation.response.statusCode);
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PREDNetRetryInterval * NSEC_PER_SEC)), dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_BACKGROUND), ^{
                                                           __strong typeof(wSelf) strongSelf = wSelf;
                                                           [strongSelf postPath:path data:data headers:headers completion:completion];
                                                       });
                                                   } else {
                                                       PREDLogDebug(@"request for url %@ succeeded, response data: %@", request.URL.absoluteString, [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);                                                       completion(operation, data, error);
                                                   }
                                               }];
    [self enqeueHTTPOperation:op];
}

- (void) enqeueHTTPOperation:(PREDHTTPOperation *) operation {
    [self.operationQueue addOperation:operation];
}

- (NSUInteger) cancelOperationsWithPath:(NSString*) path
                                 method:(NSString*) method {
    NSUInteger cancelledOperations = 0;
    for(PREDHTTPOperation *operation in self.operationQueue.operations) {
        NSURLRequest *request = operation.URLRequest;
        
        BOOL matchedMethod = YES;
        if(method && ![request.HTTPMethod isEqualToString:method]) {
            matchedMethod = NO;
        }
        
        BOOL matchedPath = YES;
        if(path) {
            //method is not interesting here, we' just creating it to get the URL
            NSURL *url = [self requestWithMethod:@"GET" path:path parameters:nil error:nil].URL;
            matchedPath = [request.URL isEqual:url];
        }
        
        if(matchedPath && matchedMethod) {
            ++cancelledOperations;
            [operation cancel];
        }
    }
    return cancelledOperations;
}

- (NSMutableURLRequest *) requestWithMethod:(NSString*) method
                                       path:(NSString *) path
                                 parameters:(NSDictionary *)params
                                      error:(NSError **)err {
    NSParameterAssert(self.baseURL);
    NSParameterAssert(method);
    NSParameterAssert(params == nil || [method isEqualToString:@"POST"] || [method isEqualToString:@"GET"]);
    path = path ? : @"";
    
    NSString* url =  [NSString stringWithFormat:@"%@%@", _baseURL, path];
    NSURL *endpoint = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    request.HTTPMethod = method;
    [NSURLProtocol setProperty:@YES
                        forKey:@"PREDInternalRequest"
                     inRequest:request];
    
    if (params) {
        if ([method isEqualToString:@"GET"]) {
            NSString *absoluteURLString = [endpoint absoluteString];
            //either path already has parameters, or not
            NSString *appenderFormat = [path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
            
            endpoint = [NSURL URLWithString:[absoluteURLString stringByAppendingFormat:appenderFormat,
                                             [self.class queryStringFromParameters:params withEncoding:NSUTF8StringEncoding]]];
            [request setURL:endpoint];
        } else {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            NSData *postBody;
            postBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:err];
            if (*err != nil) {
                return nil;
            }
            [request setHTTPBody:postBody];
        }
    }
    
    return request;
}

+ (NSString *) queryStringFromParameters:(NSDictionary *) params withEncoding:(NSStringEncoding) encoding {
    NSMutableString *queryString = [NSMutableString new];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        NSAssert([key isKindOfClass:[NSString class]], @"Query parameters can only be string-string pairs");
        NSAssert([value isKindOfClass:[NSString class]], @"Query parameters can only be string-string pairs");
        
        [queryString appendFormat:queryString.length ? @"&%@=%@" : @"%@=%@", key, value];
    }];
    return queryString;
}

- (PREDHTTPOperation*) operationWithURLRequest:(NSURLRequest*) request
                                    completion:(PREDNetworkCompletionBlock) completion {
    PREDHTTPOperation *operation = [PREDHTTPOperation operationWithRequest:request
                                    ];
    [operation setCompletion:completion];
    
    return operation;
}

@end
