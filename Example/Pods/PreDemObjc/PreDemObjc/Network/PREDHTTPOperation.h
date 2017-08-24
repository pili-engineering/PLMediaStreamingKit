//
//  PREDHTTPOperation.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PREDHTTPOperation;
typedef void (^PREDNetworkCompletionBlock)(PREDHTTPOperation* operation, NSData* data, NSError* error);

@interface PREDHTTPOperation : NSOperation

+ (instancetype) operationWithRequest:(NSURLRequest *) urlRequest;

@property (nonatomic, readonly) NSURLRequest *URLRequest;

//the completion is only called if the operation wasn't cancelled
- (void) setCompletion:(PREDNetworkCompletionBlock) completionBlock;

@property (nonatomic, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSError *error;

@end
